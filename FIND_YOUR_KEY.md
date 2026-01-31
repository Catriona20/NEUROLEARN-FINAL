# 🔑 HOW TO FIND THE CORRECT KEY

The error `Invalid API key` means the key you pasted is incorrect.
The key you used (`7Oj8a...`) is **too short**. It looks like a password, not an API key.

## 1. Go to Supabase API Settings
Go to: **Settings (⚙️) -> API**

## 2. Find "Project API keys"
Look for the box that says:

| Name | Key |
|------|-----|
| **anon** | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |
| `public` | (This is a LONG string) |

## 3. Copy the "anon" / "public" key
**Do NOT** copy the `service_role` key.
**Do NOT** copy the Project Ref.

## 4. Paste in your code
Open `lib/data/config/supabase_config.dart` and paste it carefully.

```dart
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI... (very long string) ...';
```

---

**After you update the key:**
1. Save the file.
2. Press `R` in your terminal to Hot Restart.
3. Try "Send OTP" again.
