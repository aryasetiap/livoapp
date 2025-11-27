# 📅 Livo Development Plan

Based on `SPEC.md`, `CLAUDE.md`, and `README.md`, this plan outlines the 6-week development roadmap for the Livo MVP.

## 🗓️ Phase 1: Project Setup & Authentication (Week 1)
**Goal:** Establish the project foundation and user authentication system.

- [ ] **Project Initialization**
    - [ ] Create Flutter project with recommended structure.
    - [ ] Setup `lib/core` (config, utils, widgets).
    - [ ] Setup `lib/features` directory structure.
    - [ ] Configure `flutter_riverpod`, `go_router`, `dio`.
    - [ ] Setup environment variables (`.env`).
- [ ] **Supabase Integration**
    - [ ] Initialize Supabase client.
    - [ ] Setup Supabase Auth (Email/Password, Google Sign-in).
- [ ] **Authentication Features**
    - [ ] Splash Screen (Check auth state).
    - [ ] Login Screen.
    - [ ] Signup Screen.
    - [ ] Logout functionality.
    - [ ] Password Reset.
- [ ] **Basic Profile**
    - [ ] User data model (`users` table).
    - [ ] Fetch current user profile.

## 🗓️ Phase 2: Core Features - Posting & Feed (Week 2)
**Goal:** Enable users to create content and view a feed.

- [ ] **Media Handling**
    - [ ] Image/Video Picker integration.
    - [ ] Media compression logic.
    - [ ] Supabase Storage setup (`posts` bucket).
- [ ] **Create Post**
    - [ ] Create Post Screen UI.
    - [ ] Upload logic (Media -> Storage, Data -> `posts` & `post_media` tables).
    - [ ] Background upload handling.
- [ ] **Feed System**
    - [ ] Home Feed Screen UI.
    - [ ] Fetch posts logic (Chronological).
    - [ ] Display posts (Image/Video rendering).
    - [ ] Pagination (Infinite scroll).

## 🗓️ Phase 3: Engagement (Week 3)
**Goal:** Add social interactions to posts.

- [ ] **Likes**
    - [ ] Like/Unlike logic (`likes` table).
    - [ ] Optimistic UI updates.
    - [ ] Like count display.
- [ ] **Comments**
    - [ ] Comment UI (Input & List).
    - [ ] Create comment logic (`comments` table).
    - [ ] Display comments for a post.
- [ ] **Post Detail**
    - [ ] Dedicated Post Detail Screen.
    - [ ] Deep linking support (optional for MVP but good for structure).

## 🗓️ Phase 4: Social Graph (Week 4)
**Goal:** Connect users through following and search.

- [ ] **Follow System**
    - [ ] Follow/Unfollow logic (`followers` table).
    - [ ] Update Feed to show only followed users' posts (or mixed).
    - [ ] Followers/Following count on Profile.
- [ ] **Profile Enhancements**
    - [ ] View other user's profile.
    - [ ] Edit Profile (Avatar, Bio).
    - [ ] User's post grid on profile.
- [ ] **Search**
    - [ ] Search Screen UI.
    - [ ] Search users by username (Case-insensitive).

## 🗓️ Phase 5: Realtime Chat (Week 5)
**Goal:** Implement 1-on-1 messaging.

- [ ] **Chat Infrastructure**
    - [ ] Chat data models (`chats`, `messages`).
    - [ ] Realtime subscription setup.
- [ ] **Chat UI**
    - [ ] Chat List Screen (Recent conversations).
    - [ ] Chat Room Screen (Message bubbles).
- [ ] **Messaging Logic**
    - [ ] Send text message.
    - [ ] Receive realtime updates.
    - [ ] Mark messages as seen.
- [ ] **Notifications (Chat)**
    - [ ] Push notifications for new messages (FCM).

## 🗓️ Phase 6: Moderation & Polish (Week 6)
**Goal:** Ensure safety and polish the app for release.

- [ ] **Moderation**
    - [ ] Report Post functionality (`reports` table).
    - [ ] Block User functionality (`blocked_users` table).
    - [ ] Filter content from blocked users.
- [ ] **Notifications (General)**
    - [ ] In-app notifications list.
    - [ ] Push notifications for Likes/Comments/Follows.
- [ ] **Final Polish**
    - [ ] UI/UX refinements.
    - [ ] Performance optimization.
    - [ ] Bug fixes.
- [ ] **Deployment**
    - [ ] Build release APK/AAB.
    - [ ] Verify against production Supabase instance.
