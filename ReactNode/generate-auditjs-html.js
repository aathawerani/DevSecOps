const fs = require('fs');

function generateHTMLReport(jsonData) {
    let html = `
    <html>
    <head>
        <title>AuditJS Security Report</title>
        <style>
            body { font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; }
            h1 { text-align: center; color: #333; }
            table { width: 100%; border-collapse: collapse; background: white; }
            th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
            th { background: #0073e6; color: white; }
            tr:nth-child(even) { background: #f9f9f9; }
            .severity { padding: 5px 10px; border-radius: 5px; font-weight: bold; }
            .critical { background-color: #ff4d4d; color: white; }
            .high { background-color: #ff704d; color: white; }
            .moderate { background-color: #ffa64d; }
            .low { background-color: #ffd24d; }
            .info { background-color: #d9d9d9; }
            a { color: #0073e6; text-decoration: none; font-weight: bold; }
            a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <h1>AuditJS Security Report</h1>
        <table>
            <tr>
                <th>Package</th>
                <th>Version</th>
                <th>Severity</th>
                <th>Description</th>
                <th>More Info</th>
            </tr>`;

    for (const [pkgName, details] of Object.entries(jsonData.vulnerabilities)) {
        let version = details.range || "Unknown";

        // If there are multiple advisories for this package, loop through all of them
        details.via.forEach(vuln => {
            let description = vuln.title || "No description available";
            let moreInfo = vuln.url ? `<a href="${vuln.url}" target="_blank">Details</a>` : "No advisory available";

            // Extract severity correctly
            let severity = vuln.severity || details.severity || "Unknown";
            let severityClass = severity.toLowerCase();

            html += `
            <tr>
                <td>${pkgName}</td>
                <td>${version}</td>
                <td class="severity ${severityClass}">${severity}</td>
                <td>${description}</td>
                <td>${moreInfo}</td>
            </tr>`;
        });
    }

    html += `</table></body></html>`;
    return html;
}

// Read JSON file and generate HTML
fs.readFile('npm-audit.json', 'utf8', (err, data) => {
    if (err) {
        console.error("Error reading audit file:", err);
        return;
    }
    const jsonData = JSON.parse(data);
    const htmlReport = generateHTMLReport(jsonData);
    fs.writeFileSync('npm-audit-report.html', htmlReport);
    console.log("✅ AuditJS HTML report generated: npm-audit-report.html");
});
