// =============================================================================
// API Client - Frontend → Backend 通信ヘルパー
// =============================================================================

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

/**
 * API リクエストオプション
 */
interface RequestOptions extends Omit<RequestInit, 'body'> {
  body?: unknown;
  params?: Record<string, string | number | boolean | undefined>;
}

/**
 * API エラー
 */
export class ApiClientError extends Error {
  constructor(
    public readonly statusCode: number,
    message: string,
    public readonly error?: string,
  ) {
    super(message);
    this.name = 'ApiClientError';
  }
}

/**
 * クエリパラメータを URL に付与する
 */
function buildUrl(path: string, params?: Record<string, string | number | boolean | undefined>): string {
  const url = new URL(`${API_BASE_URL}/api/v1${path}`);
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined) {
        url.searchParams.set(key, String(value));
      }
    });
  }
  return url.toString();
}

/**
 * 共通 fetch ラッパー
 */
async function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { body, params, headers: customHeaders, ...rest } = options;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(customHeaders as Record<string, string>),
  };

  const config: RequestInit = {
    ...rest,
    headers,
    ...(body !== undefined && { body: JSON.stringify(body) }),
  };

  const url = buildUrl(path, params);
  const response = await fetch(url, config);

  if (!response.ok) {
    let errorBody: { message?: string; error?: string } = {};
    try {
      errorBody = await response.json();
    } catch {
      // JSON パース失敗時はデフォルトメッセージを使う
    }
    throw new ApiClientError(
      response.status,
      errorBody.message || response.statusText,
      errorBody.error,
    );
  }

  // 204 No Content の場合は空を返す
  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

/**
 * API Client
 *
 * @example
 * ```ts
 * import { apiClient } from '@/lib/api-client';
 *
 * // GET
 * const users = await apiClient.get<ApiResponse<User[]>>('/users', { params: { page: 1 } });
 *
 * // POST
 * const newUser = await apiClient.post<ApiResponse<User>>('/users', { body: { email: 'a@b.com' } });
 *
 * // PUT
 * await apiClient.put('/users/123', { body: { name: 'New Name' } });
 *
 * // DELETE
 * await apiClient.delete('/users/123');
 * ```
 */
export const apiClient = {
  get: <T>(path: string, options?: RequestOptions) =>
    request<T>(path, { ...options, method: 'GET' }),

  post: <T>(path: string, options?: RequestOptions) =>
    request<T>(path, { ...options, method: 'POST' }),

  put: <T>(path: string, options?: RequestOptions) =>
    request<T>(path, { ...options, method: 'PUT' }),

  patch: <T>(path: string, options?: RequestOptions) =>
    request<T>(path, { ...options, method: 'PATCH' }),

  delete: <T>(path: string, options?: RequestOptions) =>
    request<T>(path, { ...options, method: 'DELETE' }),
};
