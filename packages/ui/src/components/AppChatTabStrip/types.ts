export interface ChatTabModel {
  key: string; // 'broadcast' | membershipId
  label: string;
  kind: 'broadcast' | 'whisper';
  unreadCount: number;
  presence?: 'online' | 'idle' | 'offline';
}
