/* style.css */
body {
  font-family: Poppins, sans-serif;
  background: linear-gradient(135deg, #0f172a, #1e293b);
  color: #f8fafc;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  margin: 0;
}

.container {
  width: 90%;
  max-width: 700px;
  background: #1e293b;
  padding: 20px 30px;
  border-radius: 16px;
  box-shadow: 0 0 20px rgba(0,0,0,0.3);
}

h1 {
  text-align: center;
  color: #38bdf8;
}

textarea {
  width: 100%;
  height: 200px;
  padding: 10px;
  border-radius: 8px;
  border: none;
  resize: none;
  font-family: monospace;
  background: #0f172a;
  color: #f8fafc;
}

input[type="file"] {
  width: 100%;
  padding: 8px;
  margin-top: 8px;
  background: #0f172a;
  color: #f8fafc;
  border: none;
  border-radius: 8px;
}

button {
  background: #38bdf8;
  color: #0f172a;
  font-weight: bold;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  margin-top: 10px;
  cursor: pointer;
  transition: 0.3s;
}

button:hover {
  background: #0ea5e9;
}

input[type="text"] {
  width: 100%;
  padding: 10px;
  border-radius: 8px;
  border: none;
  margin-bottom: 10px;
  background: #0f172a;
  color: #f8fafc;
}

#displayArea {
  background: #0f172a;
  border-radius: 8px;
  padding: 15px;
  min-height: 200px;
  user-select: none; /* Prevent text selection */
  pointer-events: none; /* Prevent editing */
  white-space: pre-wrap; /* Keep formatting */
}

#share-section p {
  margin-bottom: 5px;
}

embed {
  width: 100%;
  height: 500px;
  border-radius: 8px;
  background: #0f172a;
}

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Secure Read-Only File Viewer</title>
  <link rel="stylesheet" href="style.css" />
</head>
<body>
  <div class="container">
    <h1>Secure File Viewer</h1>

    <!-- Upload Section -->
    <div id="upload-section">
      <input type="file" id="fileInput" accept=".txt,.pdf" />
      <textarea id="fileContent" placeholder="Or paste text here..."></textarea>
      <button id="generateLink">Generate View Link</button>
    </div>

    <!-- Share Section -->
    <div id="share-section" style="display: none;">
      <p>Share this link with your friends (read-only):</p>
      <input type="text" id="shareLink" readonly />
      <button id="copyLink">Copy Link</button>
    </div>

    <!-- View Section -->
    <div id="view-section" style="display: none;">
      <h2>Read-Only Document</h2>
      <div id="displayArea"></div>
      <embed id="pdfViewer" type="application/pdf" style="display: none;" />
    </div>
  </div>

  <script src="script.js"></script>
</body>
</html>

// script.js
document.addEventListener('DOMContentLoaded', () => {
  const fileInput = document.getElementById('fileInput');
  const generateLinkBtn = document.getElementById('generateLink');
  const shareSection = document.getElementById('share-section');
  const uploadSection = document.getElementById('upload-section');
  const viewSection = document.getElementById('view-section');
  const shareLink = document.getElementById('shareLink');
  const copyLinkBtn = document.getElementById('copyLink');
  const displayArea = document.getElementById('displayArea');
  const pdfViewer = document.getElementById('pdfViewer');

  const urlParams = new URLSearchParams(window.location.search);
  const typeParam = urlParams.get('type');
  const dataParam = urlParams.get('data');

  // View Mode (when a link has ?type=...&data=...)
  if (dataParam && typeParam) {
    uploadSection.style.display = 'none';
    viewSection.style.display = 'block';

    if (typeParam === 'text') {
      // decodeURIComponent(atob(...))
      try {
        const decoded = decodeURIComponent(atob(dataParam));
        displayArea.style.display = 'block';
        pdfViewer.style.display = 'none';
        displayArea.textContent = decoded;
      } catch (err) {
        displayArea.textContent = 'Error decoding text content.';
      }
    } else if (typeParam === 'pdf') {
      const pdfUrl = decodeURIComponent(dataParam);
      pdfViewer.src = pdfUrl;
      pdfViewer.style.display = 'block';
      displayArea.style.display = 'none';
    }

    // Disable copying & right-click
    document.addEventListener('contextmenu', e => e.preventDefault());
    document.addEventListener('copy', e => e.preventDefault());
    document.addEventListener('keydown', e => {
      if ((e.ctrlKey && e.key === 'c') || (e.ctrlKey && e.key === 'u')) {
        e.preventDefault();
      }
    });
  }

  // Handle File Upload
  fileInput.addEventListener('change', (event) => {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    const textarea = document.getElementById('fileContent');

    if (file.type === "application/pdf") {
      reader.onload = function(e) {
        textarea.value = '';
        textarea.setAttribute('data-pdf', e.target.result);
      };
      reader.readAsDataURL(file);
    } else {
      reader.onload = function(e) {
        textarea.value = e.target.result;
      };
      reader.readAsText(file);
    }
  });

  // Generate shareable link
  generateLinkBtn.addEventListener('click', () => {
    const textarea = document.getElementById('fileContent');
    const text = textarea.value.trim();
    const pdfData = textarea.getAttribute('data-pdf');

    let link = '';
    if (pdfData) {
      link = `${window.location.origin}${window.location.pathname}?type=pdf&data=${encodeURIComponent(pdfData)}`;
    } else if (text) {
      const encoded = btoa(encodeURIComponent(text));
      link = `${window.location.origin}${window.location.pathname}?type=text&data=${encoded}`;
    } else {
      alert('Please upload or paste a file first.');
      return;
    }

    shareLink.value = link;
    shareSection.style.display = 'block';
  });

  // Copy link
  copyLinkBtn.addEventListener('click', () => {
    shareLink.select();
    try {
      document.execCommand('copy');
      copyLinkBtn.textContent = 'Copied!';
      setTimeout(() => (copyLinkBtn.textContent = 'Copy Link'), 2000);
    } catch (err) {
      alert('Copy failed. Please select and copy the link manually.');
    }
  });
});
