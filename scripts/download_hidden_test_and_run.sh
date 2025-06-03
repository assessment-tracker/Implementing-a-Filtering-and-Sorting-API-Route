# Run Node.js script to download the test case using bucket name and file path
node <<'EOF'
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const SUPABASE_URL = "https://cgkaktxdcqlgmfkfkced.supabase.co";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variable.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

(async () => {
  try {
    const bucket = 'assessment-tracker';
    const filePath = 'post_hidden.test.js';

    const { data: fileData, error: downloadError } = await supabase
      .storage
      .from(bucket)
      .download(filePath);

    if (downloadError) {
      console.error('Error downloading file from Supabase storage:', downloadError.message);
      process.exit(1);
    }

    const content = await fileData.text();
    fs.mkdirSync('tests', { recursive: true });
    fs.writeFileSync('tests/test-case-private.test.js', content);
    console.log('File downloaded successfully to tests/test-case-private.test.js');
  } catch (e) {
    console.error('Failed to download the test case:', e.message);
    process.exit(1);
  }
})();
EOF
