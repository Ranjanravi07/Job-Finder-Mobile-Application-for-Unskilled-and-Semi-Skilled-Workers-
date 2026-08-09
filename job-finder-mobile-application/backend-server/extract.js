const fs = require('fs');
const env = fs.readFileSync('.env', 'utf-8');

// Match the JSON string from FIREBASE_SERVICE_ACCOUNT=...
const match = env.match(/FIREBASE_SERVICE_ACCOUNT=(.*)/);

if (match) {
  let val = match[1];
  
  // Try to parse it directly in case dotenv already unescaped it when we ran the previous script
  try {
    const parsed = JSON.parse(val);
    fs.writeFileSync('serviceAccountKey.json', JSON.stringify(parsed, null, 2));
    console.log('Successfully wrote serviceAccountKey.json');
  } catch (e) {
    // If it fails, maybe it has surrounding quotes that need to be removed, and escaped quotes that need to be unescaped
    if (val.startsWith('"') && val.endsWith('"')) {
      val = val.slice(1, -1); // remove outer quotes
      
      // Unescape \" and \n
      val = val.replace(/\\"/g, '"');
      val = val.replace(/\\n/g, '\n');
      
      try {
        const parsed2 = JSON.parse(val);
        fs.writeFileSync('serviceAccountKey.json', JSON.stringify(parsed2, null, 2));
        console.log('Successfully unescaped and wrote serviceAccountKey.json');
      } catch (e2) {
        console.error('Failed to parse even after unescaping:', e2.message);
      }
    } else {
      console.error('Failed to parse JSON directly, and it does not have outer quotes:', e.message);
    }
  }
} else {
  console.log('FIREBASE_SERVICE_ACCOUNT not found in .env');
}
