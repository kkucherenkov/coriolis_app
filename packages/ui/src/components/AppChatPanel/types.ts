// Re-export the existing AppChatMessage props from its component;
// since AppChatMessage uses defineProps without an extracted interface,
// we mirror the prop shape here so the panel can type the messages array.
export interface AppChatPanelMessagePayload {
  variant: 'broadcast-author' | 'broadcast-other' | 'whisper' | 'system';
  authorDisplayName?: string;
  authorAvatarSrc?: string | null;
  authorPresence?: 'online' | 'idle' | 'offline';
  body?: string | null;
  systemLabel?: string;
  createdAtIso: string;
  editedAtIso?: string | null;
  deletedAtIso?: string | null;
  ownByMe: boolean;
  ownByGm: boolean;
  canEdit: boolean;
  canDelete: boolean;
  canBlock: boolean;
}

export interface AppChatPanelDayDividerPayload {
  label: string;
}

export type AppChatPanelRow =
  | {
      id: string;
      variant: 'broadcast-author' | 'broadcast-other' | 'whisper' | 'system';
      payload: AppChatPanelMessagePayload;
    }
  | { id: string; variant: 'day-divider'; payload: AppChatPanelDayDividerPayload };

export type AppChatPanelConnectionStatus =
  | 'connecting'
  | 'subscribed'
  | 'unrecoverable'
  | 'disconnected';

export type AppChatPanelMode = 'primary' | 'docked';

export type { ChatTabModel } from '../AppChatTabStrip/types';
