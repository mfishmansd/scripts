# Deploying the SPFx Favicon Customizer Solution

This guide details the steps for deploying the `favicon-customizer.sppkg` SPFx solution in SharePoint, enabling a custom favicon for your SharePoint tenant.

## Prerequisites

- SharePoint admin or Global admin access is required.
- The `favicon-customizer.sppkg` file.
- A `.ico` file for the favicon.

## Step 1: Upload the Favicon File

Begin by uploading the favicon file to a location in SharePoint accessible by all users:

### Choose a SharePoint Document Library

- Select a document library that is accessible to all users, preferably in the root site.

### Upload Favicon

- Navigate to the selected library.
- Upload your `.ico` file.
- Ensure the file is shared appropriately and accessible to all users.

### Copy Favicon URL

- Click on the uploaded favicon file.
- Copy the URL of the file for later use.

## Step 2: Deploy the SPFx Solution

Deploy the `favicon-customizer.sppkg` file to your SharePoint tenant:

### Access SharePoint Admin Center

- Log in to the SharePoint Online Admin Center.

### Navigate to the App Catalog

- Go to `App Catalog` > `Distribute apps for SharePoint`.
- If an App Catalog is not available, create one under `More features` > `Apps`.

### Upload the Solution

- In the App Catalog, go to `Apps for SharePoint`.
- Upload the `favicon-customizer.sppkg` file.

### Deploy the Solution

- Upon uploading, check the box to make the solution available to all sites in the organization for tenant-wide deployment.
- Click `Deploy`.

## Step 3: Update Component Properties in Tenant Wide Extensions

Update the component properties of the Favicon Customizer in the Tenant Wide Extensions list:

### Access Tenant Wide Extensions List

- In the App Catalog, find and open the `Tenant Wide Extensions` list.

### Update the Favicon Customizer Properties

- Locate the item with the `Component Id` corresponding to the Favicon Customizer.
- Edit the item and update the **Component Properties** field with the copied favicon URL:

  ```json
  {
    "faviconpath": "https://[Your SharePoint URL]/path/to/favicon.ico"
  }
  ```

- Replace the URL with the actual URL of your favicon.

## Completion

After following these steps, your SharePoint tenant should display the new favicon. Note that changes might not be immediately visible due to browser caching.

- Ensure the favicon URL is secure (`https`) and accessible to all users in the tenant.
- Adhere to your organization's governance policies when deploying custom solutions.
- Consult SharePoint developer documentation or seek assistance from a SharePoint expert if you encounter issues.
