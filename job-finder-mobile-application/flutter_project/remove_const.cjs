const fs = require('fs');
const path = require('path');

function getFiles(dir, files = []) {
  const list = fs.readdirSync(dir);
  for (const file of list) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      getFiles(fullPath, files);
    } else if (fullPath.endsWith('.dart')) {
      files.push(fullPath);
    }
  }
  return files;
}

const files = getFiles('lib');
let totalReplaced = 0;

for (const file of files) {
  let content = fs.readFileSync(file, 'utf8');
  let original = content;

  let iterations = 0;
  while (iterations < 1000) {
    iterations++;
    
    let indexes = [];
    let i = -1;
    while ((i = content.indexOf('AppColors.', i + 1)) !== -1) {
      indexes.push(i);
    }
    
    if (indexes.length === 0) break;
    
    let changed = false;
    for (let index of indexes) {
      let before = content.substring(0, index);
      let limit = Math.max(
        before.lastIndexOf(';'),
        before.lastIndexOf('{'),
        before.lastIndexOf('}'),
        before.lastIndexOf('=')
      );
      
      let searchArea = before.substring(limit + 1);
      
      let constIndex = searchArea.lastIndexOf('const ');
      if (constIndex !== -1) {
        let absoluteConstIndex = limit + 1 + constIndex;
        content = content.substring(0, absoluteConstIndex) + content.substring(absoluteConstIndex + 6);
        changed = true;
        break; 
      }
    }
    
    if (!changed) break;
  }
  
  if (content !== original) {
    fs.writeFileSync(file, content, 'utf8');
    totalReplaced++;
  }
}

console.log(`Replaced const in ${totalReplaced} files.`);
