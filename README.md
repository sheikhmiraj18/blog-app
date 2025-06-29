# 📝 Flutter Blog App

A sleek and minimal blog app built using **Flutter** and **Firebase**. Users can sign up, post blogs, comment on other blogs, and interact with others.

---

## 📸 Screenshots


- Login
  <p align="center">
  <img src="screenshots/login.jpeg" width="350" />
  </p>
- Signup
  <p align="center">
  <img src="screenshots/signup.jpeg" width="350" />
  </p>
- Explore
  <p align="center">
  <img src="screenshots/explore.jpeg" width="350" />
  </p>
- Blog Detail
  <p align="center">
  <img src="screenshots/blog_detail.jpeg" width="350" />
  </p>
- Create Blog
  <p align="center">
  <img src="screenshots/create.jpeg" width="350" />
  </p>
- Edit Blog
  <p align="center">
  <img src="screenshots/edit.jpeg" width="350" />
  </p>
- Profile Screen
  <p align="center">
  <img src="screenshots/profile.jpeg" width="350" />
  </p>
- User Profile Screen
  <p align="center">
  <img src="screenshots/user_profile.jpeg" width="350" />
  </p>
- Following Screen
  <p align="center">
  <img src="screenshots/following.jpeg" width="350" />
  </p>
- Comments
  <p align="center">
  <img src="screenshots/comments.jpeg" width="350" />
  </p>


## 🎥 Demo / Screen Recording

- [Watch Demo Video](https://drive.google.com/file/d/1MRH9kc5pP97CGkFJGtQP5ieZ8TuntTOr/view?usp=drivesdk) 

---

## 💡 Core Features

-  **Authentication** — Login & Signup via Firebase Auth  
-  **Blog Management** — Create, edit, and delete blog posts  
-  **Likes** — Like/unlike blog posts with real-time feedback  
-  **Comments** — Add and view comments on blogs  
-  **Profiles** — View author details and your own profile  
-  **Live Updates** — Real-time Firestore data sync  
-  **Responsive UI** — Clean, modern, and adaptive layout  
-  **Provider Architecture** — Scalable and maintainable state management  

---

## 🧾 Firestore Schemas

###  `users` Collection

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

###  `blogs` Collection

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

###  `comments` Collection

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

