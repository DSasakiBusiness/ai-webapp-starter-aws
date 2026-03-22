---
name: implement-nestjs-api
description: NestJS でモジュール・コントローラー・サービスを実装する手順
---

# Implement NestJS API

## この skill を使う場面

- 新しい API エンドポイントを追加する場合
- 既存の API を改修する場合
- 新しいドメインモジュールを作成する場合

## 入力前提

- write-api-contract で定義された API 契約（エンドポイント、入出力型）
- implement-prisma-schema で定義されたデータモデル
- tdd-coach が定義した受け入れ条件

## 実行手順

### Step 1: モジュール構成の決定

```
apps/api/src/
└── modules/
    └── [domain]/
        ├── [domain].module.ts        # モジュール定義
        ├── [domain].controller.ts    # コントローラー
        ├── [domain].controller.spec.ts # コントローラーテスト
        ├── [domain].service.ts       # サービス（ビジネスロジック）
        ├── [domain].service.spec.ts  # サービステスト
        └── dto/
            ├── create-[domain].dto.ts  # 作成 DTO
            └── update-[domain].dto.ts  # 更新 DTO
```

### Step 2: テストファーストで実装

1. サービスのユニットテストを先に書く
2. 最小限の実装でテストを通す
3. コントローラーのテストを書く
4. コントローラーを実装する
5. リファクタリングする

```typescript
// [domain].service.spec.ts
describe('DomainService', () => {
  let service: DomainService;
  let prisma: DeepMockProxy<PrismaClient>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        DomainService,
        { provide: PrismaService, useValue: mockDeep<PrismaClient>() },
      ],
    }).compile();

    service = module.get(DomainService);
    prisma = module.get(PrismaService);
  });

  describe('findAll', () => {
    it('should return all items', async () => {
      const items = [{ id: '1', name: 'test' }];
      prisma.domain.findMany.mockResolvedValue(items);
      expect(await service.findAll()).toEqual(items);
    });
  });
});
```

### Step 3: DTO とバリデーション

```typescript
// dto/create-[domain].dto.ts
import { IsString, IsNotEmpty, MaxLength } from 'class-validator';

export class CreateDomainDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name: string;
}
```

### Step 4: サービス実装

```typescript
// [domain].service.ts
@Injectable()
export class DomainService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(): Promise<Domain[]> {
    return this.prisma.domain.findMany();
  }

  async findOne(id: string): Promise<Domain> {
    const item = await this.prisma.domain.findUnique({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Domain ${id} not found`);
    }
    return item;
  }

  async create(dto: CreateDomainDto): Promise<Domain> {
    return this.prisma.domain.create({ data: dto });
  }
}
```

### Step 5: コントローラー実装

```typescript
// [domain].controller.ts
@Controller('api/v1/[domain]')
export class DomainController {
  constructor(private readonly service: DomainService) {}

  @Get()
  findAll(): Promise<Domain[]> {
    return this.service.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<Domain> {
    return this.service.findOne(id);
  }

  @Post()
  @UsePipes(new ValidationPipe({ whitelist: true }))
  create(@Body() dto: CreateDomainDto): Promise<Domain> {
    return this.service.create(dto);
  }
}
```

### Step 6: モジュール登録

```typescript
// [domain].module.ts
@Module({
  controllers: [DomainController],
  providers: [DomainService],
  exports: [DomainService],
})
export class DomainModule {}
```

## 判断ルール

- サービスが 200 行を超える場合: ドメインの分割を検討する
- 複数のモジュールが同じテーブルを操作する場合: 共有サービスを作る
- AI 機能と連携する場合: ai-engineer が実装したサービスを DI で注入する

## 出力形式

- モジュール、コントローラー、サービス、DTO の TypeScript ファイル
- 各ファイルのテストファイル（`.spec.ts`）
- エラーレスポンスは `{ statusCode, message, error }` 形式

## 注意点

- コントローラーにビジネスロジックを書かない（サービスに委譲）
- DB 操作はサービスレイヤーに閉じる
- `any` 型禁止
- エラーは NestJS の組み込み例外（NotFoundException 等）を使う
- ValidationPipe を全エンドポイントに適用する

## 失敗時の扱い

- Prisma スキーマが未定義: implement-prisma-schema skill を先に実行する
- 型の不整合: `prisma generate` を再実行する
- テストが通らない: モックの設定を確認し、Prisma Client の型と一致させる
