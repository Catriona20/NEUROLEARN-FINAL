# 🚨 ACTION REQUIRED: RATE LIMIT BLOCKS ALL EMAILS

## 🛑 The Issue
You are seeing `429 Rate Limit` even with a fresh email.
This means you have hit the **GLOBAL PROJECT LIMIT**.

Supabase protects free projects by allowing only a small number of emails (e.g., 3-5) per hour for the **entire project**.
Once this limit is reached, **NO ONE** can log in, even with a new email.

## 🛠️ THE ONLY FIX (Takes 30 seconds)

You **MUST** change this setting in your Supabase Dashboard to continue testing.

1. **Click this link**: [Open Supabase Dashboard](https://supabase.com/dashboard/project/_/settings/auth)
   *(If that link is generic, go to your project -> Settings -> Auth)*

2. Go to **Authentication** -> **Rate Limits**.

3. **CHANGE THESE TWO VALUES**:
   - **Email OTP**: Change to `100` / hour.
   - **Sign Up**: Change to `100` / hour.

4. **Click SAVE** (Bottom right).

## ⚡ TEST AGAIN
After saving:
1. Wait 30 seconds.
2. Hard Refresh the App (Cmd+R / Ctrl+R or Restart).
3. Click "Send OTP".

It **will work** immediately after you save that setting.
I cannot bypass this security setting from the code. It is a server-side switch.
