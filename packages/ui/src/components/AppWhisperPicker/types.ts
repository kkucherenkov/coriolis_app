export interface WhisperPickerMember {
  membershipId: string;
  displayName: string;
  characterName?: string | null;
  presence: 'online' | 'idle' | 'offline';
  blockedByMe: boolean;
}
