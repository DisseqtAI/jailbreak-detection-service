# 🔐 GitHub Secrets Setup Guide

## 📍 Where to Add Secrets
Go to: https://github.com/DisseqtAI/jailbreak-detection-service/settings/secrets/actions

## 🔑 Required Secrets

### **1. GCP Project Configuration**
```
Name: GCP_PROJECT_ID
Value: staging-466807
```

```
Name: GCP_SERVICE_NAME  
Value: jailbreak-detection-service
```

```
Name: GCP_REGION
Value: us-central1
```

### **2. GCP Authentication**
```
Name: GCP_WORKLOAD_IDENTITY_PROVIDER
Value: projects/153234750524/locations/global/workloadIdentityPools/github-actions/providers/github
```

```
Name: GCP_SERVICE_ACCOUNT
Value: github-actions@staging-466807.iam.gserviceaccount.com
```



## 🚀 How to Add Secrets

1. **Navigate to Repository Settings**
   - Go to https://github.com/DisseqtAI/jailbreak-detection-service
   - Click **Settings** tab
   - Click **Secrets and variables** → **Actions**

2. **Add Each Secret**
   - Click **New repository secret**
   - Enter the **Name** and **Value** from above
   - Click **Add secret**
   - Repeat for all 5 secrets

3. **Verify Secrets Added**
   - You should see all 5 secrets listed
   - Names should match exactly (case-sensitive)

## ✅ Benefits of Using Secrets

- **🔒 Security**: Sensitive values not exposed in code
- **🔄 Flexibility**: Easy to change values without code changes  
- **🌍 Reusability**: Same workflow can work for different environments
- **📊 Audit**: GitHub tracks secret usage and changes
- **👥 Team Access**: Controlled access to sensitive information

## 🧪 Testing After Setup

After adding secrets, trigger a new deployment:
1. Go to **Actions** tab
2. Click **Deploy to Staging Cloud Run**
3. Click **Run workflow**
4. Use default values and run

The workflow should now use secrets instead of hardcoded values! 