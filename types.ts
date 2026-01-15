
export enum PostType {
  STORY = 'story',
  REFLECTION = 'reflection',
  GRATITUDE = 'gratitude',
  RELAPSE = 'relapse',
  DUA = 'dua'
}

export type AffirmationType = 'I hear you' | 'You’re not alone' | 'May Allah ease this' | 'Aamin';

export interface Comment {
  id: string;
  author: string;
  authorId?: string;
  content: string;
  timestamp: Date;
  replies?: Comment[];
}

export interface Post {
  id: string;
  author: string;
  authorId?: string; // Optional for optimistic UI, required from DB
  type: PostType;
  content: string;
  timestamp: Date;
  tags: string[];
  affirmations: Record<AffirmationType, number>;
  comments: Comment[];
}

export enum NotificationType {
  AFFIRMATION = 'affirmation',
  COMMENT = 'comment',
  REPLY = 'reply'
}

export interface Notification {
  id: string;
  type: NotificationType;
  fromUser: string;
  postId: string;
  postPreview: string;
  timestamp: Date;
  isRead: boolean;
  extraInfo?: string; // e.g., which affirmation was used
}

export interface JournalPrompt {
  id: string;
  text: string;
  category: 'Faith' | 'Mind' | 'Growth' | 'Philosophy';
  description: string;
}

export interface JournalEntry {
  id: string;
  title: string;
  content: string;
  date: string;
  mood: string;
  promptId?: string;
}

export interface ReflectionResponse {
  message: string;
  wisdom: string;
  actionStep: string;
}

export interface PathPhase {
  id: string;
  name: string;
  description: string;
  indicator: string;
}
