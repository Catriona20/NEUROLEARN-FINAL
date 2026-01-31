# 📧 UPGRADE TO UNLIMITED EMAILS (GMAIL SMTP)

The "2 emails/hour" limit is stuck because you are using Supabase's **free built-in mailer**.
To get **unlimited emails** (and a real "dynamic model"), you must connect your own Gmail.

## 🛠️ STEP 1: Get a Google App Password
(You cannot use your normal password. You need a special one).

1. Go to your **[Google Account Security](https://myaccount.google.com/security)**.
2. Enable **2-Step Verification** (if not on).
3. Search for **"App Passwords"** (in search bar at top).
4. Create a new App Password:
   - App name: `Supabase`
   - Click **Create**.
   - **COPY the 16-character password** (yellow box).

## 🛠️ STEP 2: Configure Supabase
1. Go to **[Supabase Dashboard -> Settings -> Auth -> Email Providers](https://supabase.com/dashboard/project/_/settings/auth)**.
2. Toggle **Enable Custom SMTP** to **ON**.
3. Fill in these details:
   - **Sender Email**: `your-email@gmail.com`
   - **Sender Name**: `NeuroLearn`
   - **Host**: `smtp.gmail.com`
   - **Port**: `465`
   - **Username**: `your-email@gmail.com`
   - **Password**: `paste-your-16-char-app-password-here`
   - **Secure Connection**: Toggle **ON** (SSL).

4. Click **Save**.

## 🚀 RESULT
- Rate limits are GONE (Google handles 500+ emails/day).
- Emails come from *your* address.
- Your app works 100% dynamically.

**Try this setting, and then the app will work instantly.**
