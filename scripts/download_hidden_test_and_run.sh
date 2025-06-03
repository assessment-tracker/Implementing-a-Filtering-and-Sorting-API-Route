#!/bin/bash
set -e

# Extract assessment name
IFS='_' read -ra parts <<< "$REPO_NAME"
export ASSESSMENT_NAME="${parts[0]}"


echo "Assessment Name derived from REPO_NAME: $ASSESSMENT_NAME"

# Run Node.js script to fetch and download test case
node <<'EOF'
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const SUPABASE_URL = "https://cgkaktxdcqlgmfkfkced.supabase.co";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
console.log("logging_Service_Rol",SUPABASE_SERVICE_ROLE_KEY)

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variable.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);


(async () => {
  const Assessment_Name = process.env.ASSESSMENT_NAME;

  // Fetch data from the 'assessments' table
  const { data, error } = await supabase
    .from('assessments')
    .select('*')
    .eq('name', Assessment_Name);

  if (error) {
    console.error('Supabase error:', error.message);
    process.exit(1);
  }
  if (!data || data.length === 0) {
    console.error('No rows returned from Supabase.');
    process.exit(1);
  }

  const hidden_test_cases_link = data[0]?.hidden_test_cases_link;
  if (!hidden_test_cases_link) {
    console.error('No file link found in record.');
    process.exit(1);
  }

  try {
    // Parse the signed URL
    const url = new URL(hidden_test_cases_link);
    const pathname = url.pathname;
    const parts = pathname.split('/').filter(part => part !== '');

    // Validate URL structure: /storage/v1/object/sign/{bucket}/{path}
    if (parts.length < 5 || parts[0] !== 'storage' || parts[1] !== 'v1' || 
        parts[2] !== 'object' || parts[3] !== 'sign') {
      throw new Error('Invalid storage URL format.');
    }

    // Extract bucket and path
    const bucket = parts[4];
    const path = parts.slice(5).join('/');

    if (!bucket || !path) {
      throw new Error('Bucket or path not found in URL.');
    }

    // Download the file using Supabase storage API
    const { data: fileData, error: downloadError } = await supabase.storage
      .from(bucket)
      .download(path);

    if (downloadError) {
      console.error('Error downloading file from Supabase storage:', downloadError.message);
      process.exit(1);
    }

    // Convert file data to text and save it
    const content = await fileData.text();
    fs.writeFileSync('tests/test-case-private.test.js', content);
    console.log('File downloaded successfully to tests/test-case-private.test.js');
  } catch (e) {
    console.error('Failed to process or download the test case:', e.message);
    process.exit(1);
  }
})();
EOF

# Run unit tests silently
echo "Tests downloaded. Jest will be run in the workflow."
exit 0