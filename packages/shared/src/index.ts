// =============================================================================
// Shared Types - API Response & Common Types
// =============================================================================

/**
 * 汎用 API レスポンス型
 */
export interface ApiResponse<T> {
  data: T;
  meta?: PaginationMeta;
}

/**
 * ページネーションメタ情報
 */
export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

/**
 * API エラーレスポンス
 */
export interface ApiError {
  statusCode: number;
  message: string;
  error: string;
}

/**
 * ユーザーロール
 */
export type UserRole = 'USER' | 'ADMIN';

/**
 * ユーザー型
 */
export interface User {
  id: string;
  email: string;
  name: string | null;
  role: UserRole;
  createdAt: string;
  updatedAt: string;
}

/**
 * AI チャットメッセージ型
 */
export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

/**
 * AI レスポンス型
 */
export interface AiResponse {
  content: string;
  model: string;
  usage: TokenUsage;
}

/**
 * トークン使用量
 */
export interface TokenUsage {
  promptTokens: number;
  completionTokens: number;
  totalTokens: number;
}

/**
 * AI ストリーミングチャンク
 */
export interface AiStreamChunk {
  type: 'content' | 'done' | 'error';
  content?: string;
  error?: string;
  usage?: TokenUsage;
}
