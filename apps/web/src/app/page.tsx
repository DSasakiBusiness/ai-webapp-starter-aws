export default function HomePage() {
  return (
    <main
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '100vh',
        fontFamily: 'system-ui, sans-serif',
      }}
    >
      <h1>AI Webapp Starter</h1>
      <p>AI 特化 Web サービス開発用スターターリポジトリ</p>
      <p>
        <code>apps/web/src/app/page.tsx</code> を編集して開発を始めてください。
      </p>
    </main>
  );
}
