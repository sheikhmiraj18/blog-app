# 📝 Flutter Blog App

A sleek and minimal blog app built using **Flutter** and **Firebase**. Users can sign up, post blogs, comment on other blogs, and interact with others.

---

## 📸 Screenshots


- Login
- Signup
- Explore
- Blog Detail
- Create Blog
- Edir Blog
- Profile Screen
- User Profile Screen
- Followers Screen

<!-- Upload screenshots below -->
<p align="center">
  <img src="screenshots/login.png" width="200" />
  <img src="screenshots/feed.png" width="200" />
  <img src="screenshots/blog_detail.png" width="200" />
  <img src="screenshots/profile.png" width="200" />
</p>

---

## 🎥 Demo / Screen Recording

> Embed your video or GIF demo here.

- [📽️ Watch Demo Video](#)  
- Or add a short GIF showing app flow

---

## 💡 Core Features

- 🔐 **Authentication** — Login & Signup via Firebase Auth  
- 📝 **Blog Management** — Create, edit, and delete blog posts  
- ❤️ **Likes** — Like/unlike blog posts with real-time feedback  
- 💬 **Comments** — Add and view comments on blogs  
- 👤 **Profiles** — View author details and your own profile  
- 🔄 **Live Updates** — Real-time Firestore data sync  
- 🎨 **Responsive UI** — Clean, modern, and adaptive layout  
- 🧩 **Provider Architecture** — Scalable and maintainable state management  

---

## 🧾 Firestore Schemas

### 🧑‍💼 `users` Collection

```json
{
  "uid": "string",
  "username": "string",
  "email": "string",
  "profileImageUrl": "string",
  "bio": "string",
  "createdAt": "timestamp"
}
```

### 🧑‍💼 `blogs` Collection

```json
{
  "id": "string",
  "title": "string",
  "content": "string",
  "authorId": "string",
  "authorUsername": "string",
  "authorProfileImageUrl": "string",
  "likes": ["uid1", "uid2"],
  "comments": ["commentId1"],
  "createdAt": "timestamp"
}
```

### 🧑‍💼 `comments` Collection

```json
{
  "id": "string",
  "blogId": "string",
  "userId": "string",
  "username": "string",
  "profileImageUrl": "string",
  "content": "string",
  "createdAt": "timestamp"
}
```

