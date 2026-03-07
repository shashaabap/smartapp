// frontend/lib/config.ts
// export const config = {
//   API_URL: 'http://filatex.smartapp.com:4000',
// } as const;

export const config = {
  API_URL:
    typeof window !== 'undefined'
      ? `${window.location.protocol}//${window.location.hostname}:4000`
      : process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000'
};