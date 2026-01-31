# 📧 FIX: GET CODE INSTEAD OF LINK

The issue is that your **Supabase Email Template** is still set to send a "Magic Link".
You need to change it to send just the **Numeric Code**.

## 🛠️ AUTO-FIX (Dashboard)

1. Go to **[Supabase Dashboard -> Settings -> Auth -> Email Templates](https://supabase.com/dashboard/project/_/settings/auth)**.
   *(Or click 'Email Templates' in the Auth menu)*

2. Find the **"Magic Link"** template (sometimes called "Sign In").
   - **Note**: Check "Confirm Signup" as well if you are a new user.

3. **CHANGE THE CONTENT** to this:

   **Subject:**
   `Beep Boop! Your Login Code is {{ .Token }}`

   **Body:**
   ```html
   <h2>Hello!</h2>
   <p>Your login code is:</p>
   <h1>{{ .Token }}</h1>
   <p>Enter this code in the app to log in.</p>
   ```

4. **IMPORTANT**:
   - remove any variable that looks like `{{ .ConfirmationURL }}`
   - Ensure you use `{{ .Token }}`

5. **Click Save**.

## 🚀 TRY AGAIN
1. Go to App.
2. Send OTP.
3. You will now get an email with a **BIG NUMBER** instead of a link!
