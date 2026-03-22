import { render, screen } from '@testing-library/react';
import HomePage from './page';

describe('HomePage', () => {
  it('should render the heading', () => {
    render(<HomePage />);

    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('AI Webapp Starter');
  });

  it('should render the description', () => {
    render(<HomePage />);

    expect(screen.getByText(/AI 特化 Web サービス/)).toBeInTheDocument();
  });

  it('should render the getting started instruction', () => {
    render(<HomePage />);

    expect(screen.getByText('apps/web/src/app/page.tsx')).toBeInTheDocument();
  });
});
