# 🟦 **TECH SPEC – LIVO (MVP)**

## 📌 **1. Product Summary**

**Livo** adalah aplikasi sosial media berbasis Android (Flutter) yang memungkinkan pengguna untuk:

- Membuat akun
- Mengunggah foto/video pendek
- Melihat feed
- Like & comment
- Follow/unfollow
- Mengirim pesan (chat 1-on-1 real-time)
- Menerima notifikasi push

MVP fokus pada **kesederhanaan**, **kecepatan**, **real-time**, dan **user engagement dasar**.

---

# 🟩 **2. Target Platform**

- Android (min SDK 21)
- Dibangun dengan Flutter 3.24+
- Tablet support opsional

---

# 🟪 **3. Tech Stack**

### Frontend (Flutter)

- **Framework:** Flutter
- **State management:** Riverpod (preferred) atau Bloc
- **Routing:** GoRouter
- **HTTP:** Dio
- **Local storage:** Hive / SharedPreferences
- **Image/video picker:** `image_picker`
- **Video player:** `video_player`
- **Background upload:** `flutter_uploader` / isolate
- **Real-time:** Supabase Realtime client
- **Push notif:** Firebase Messaging

### Backend

- **Supabase (primary backend)**
  - Supabase Auth
  - Postgres database
  - Supabase Storage (media)
  - Supabase Realtime (chat + feed notifs)
  - RLS (Row Level Security)

### Media Storage

- Supabase Storage (MVP)
- Opsional: Cloudflare R2 (production scale)

### DevOps

- GitHub Actions (CI)
- Fastlane (build & sign APK/AAB)

---

# 🟨 **4. Core MVP Features**

### 4.1 Auth

- Signup email & Google
- Login
- Logout
- Reset password

### 4.2 Profile

- View profile (foto, bio, posts)
- Edit profile
- Follow/unfollow
- Followers & following count

### 4.3 Posts

- Upload photo (jpg/png)
- Upload video (<15s)
- Caption
- Feed chronological
- Like / Unlike
- Comment
- View post detail

### 4.4 Chat (1-on-1)

- Realtime text chat
- Chat list (last message)
- Seen/unseen message
- Push notification for new message

### 4.5 Search

- Search users by username

### 4.6 Notifications

- Realtime in-app notif (Supabase)
- Push notif (FCM):
  - New message
  - New follower
  - Like/comment

### 4.7 Moderation

- Report post
- Block user

---

# 🟥 **5. Data Model (Postgres)**

### users

```
id (uuid)
username (text unique)
email (text unique)
bio (text)
avatar_url (text)
created_at (timestamp)
```

### posts

```
id (uuid)
user_id (uuid references users)
caption (text)
created_at (timestamp)
```

### post_media

```
id (uuid)
post_id (uuid references posts)
media_url (text)
thumbnail_url (text)
type (enum: 'photo' | 'video')
width (int)
height (int)
duration (int nullable)
```

### followers

```
id (uuid)
follower_id (uuid references users)
followee_id (uuid references users)
created_at (timestamp)
```

### likes

```
id (uuid)
user_id (uuid)
post_id (uuid)
created_at (timestamp)
```

### comments

```
id (uuid)
post_id (uuid)
user_id (uuid)
text (text)
created_at (timestamp)
```

### chats

```
id (text)  // format: smallerUserId_biggerUserId
user_a (uuid)
user_b (uuid)
updated_at (timestamp)
```

### messages

```
id (uuid)
chat_id (text)
sender_id (uuid)
text (text)
seen (bool)
created_at (timestamp)
```

### reports

```
id (uuid)
post_id (uuid)
reporter_id (uuid)
reason (text)
created_at (timestamp)
```

### blocked_users

```
id (uuid)
user_id (uuid)
blocked_user_id (uuid)
created_at (timestamp)
```

---

# 🟦 **6. API Spec (via Supabase)**

Supabase akan expose RPC atau standard CRUD melalui:

### Auth

- `supabase.auth.signInWithPassword()`
- `supabase.auth.signUp()`

### Posts

- `POST /posts` → create post
- Upload media → Supabase Storage bucket `posts/`
- `GET /feed?limit=x&cursor=y` → feed chronological
- `GET /posts/:id`
- `GET /posts/user/:userId`

### Likes

- `POST /likes`
- `DELETE /likes/:id`

### Comments

- `POST /comments`
- `GET /comments/:postId`

### Follow

- `POST /followers`
- `DELETE /followers/:id`

### Chat

Realtime channel:
`supabase.channel('chat:{chatId}').on('postgres_changes')`

API:

- `GET /chats` – list chat rooms
- `GET /messages/:chatId`
- `POST /messages`
- Listener untuk realtime

### Search

- Simple search menggunakan SQL `ilike '%query%'`

### Notifications

- Insert triggers pada:
  - likes → notify user
  - comments → notify user
  - messages → notify user

Gunakan webhook → Cloud Function → FCM send.

---

# 🟩 **7. User Flow Specs**

### Auth Flow

1. Splash → cek token
2. Onboarding (optional)
3. Login / signup
4. Redirect ke Home

### Posting Flow

1. User pilih foto/video
2. Compress (client)
3. Upload ke Supabase Storage
4. Insert row ke `posts` + `post_media`
5. Feed update realtime (optional)

### Feed Flow

- Query posts dari user yang di-follow
- Jika kosong, tampilkan explore basic

### Chat Flow

1. A membuka profile B → klik “Message”
2. Cek apakah chat room sudah ada:
   - Jika belum, buat: id = sort(userA, userB)
3. A kirim pesan → masuk tabel `messages`
4. Realtime listeners update UI

### Follow Flow

- Insert row ke followers
- Update feed content

---

# 🟦 **8. Flutter App Architecture**

### State Management

- Riverpod (recommended)

### Directory Structure

```
/lib
    /core
        /config
        /exceptions
        /utils
        /widgets
    /features
        /auth
            /data
            /domain
            /presentation
        /profile
        /post
        /feed
        /chat
        /search
        /notifications
    /services
        supabase_client.dart
        fcm_service.dart
    main.dart
```

### Naming Conventions

- provider: `xxxProvider`
- repository: `xxxRepository`
- service: `xxxService`
- view models: `xxxController`

---

# 🟧 **9. Components List (UI)**

### Global UI Components

- LivoAppBar
- Avatar(imageUrl, size)
- PostCard
- MediaViewer
- CommentTile
- UserTile
- ChatBubble
- LoadingSpinner
- EmptyState

### Screens

- SplashScreen
- LoginScreen
- SignupScreen
- HomeFeedScreen
- CreatePostScreen
- PostDetailScreen
- ProfileScreen
- EditProfileScreen
- ChatListScreen
- ChatRoomScreen
- SearchScreen
- SettingsScreen

---

# 🟥 **10. Rules & Logic Specs**

### Posting Rules

- Max video: 15 seconds
- Max resolution: 1080p
- Captions: max 300 chars

### Chat Rules

- Typing indicator tidak perlu di MVP
- Pesan hanya teks (emoji allowed)
- Seen status wajib

### Feed Rules

- Default chronological
- Only posts from followed users

### Search Rules

- Search hanya username, case-insensitive

### Block Rules

- Jika A block B:
  - A tidak melihat post B
  - Chat disable
  - Follow otomatis di-remove

---

# 🟩 **11. Security & RLS (Row Level Security)**

### Posts

```
user_id = auth.uid()
```

### Messages

```
chat.user_a = auth.uid() OR chat.user_b = auth.uid()
```

### Followers

```
follower_id = auth.uid()
```

### Blocked Users

No reads unless user_id = auth.uid()

---

# 🟦 **12. Development Roadmap (6 Weeks)**

### Week 1

- Project setup
- Auth system
- Profile basic

### Week 2

- Create post
- Media upload
- Feed list

### Week 3

- Likes
- Comments
- Post detail

### Week 4

- Follow system
- Profile view
- Search user

### Week 5

- Chat system (realtime)
- Chat list
- Push notif for messages

### Week 6

- Block/report
- Final polishing
- Build release AAB

---

# 🟫 **13. Deliverables Needed for Coding**

Claude / developer akan dapat langsung membuat:

1. Project Flutter lengkap
2. UI layout + reusable components
3. Supabase client integration
4. Feed, posting, chat endpoints
5. DB migrations SQL
6. Riverpod providers + repository pattern
7. Automated tests (optional)
8. APK/AAB ready for deployment
