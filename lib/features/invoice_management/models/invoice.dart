class Invoice {
  String? invoiceNo;
  String? issuedDate; // "YYYY-MM-DD"
  String? dueDate;    // for Paid tab we label as "Paid At"
  String? status;     // Paid/Unpaid
  num? totalAmount;
  String? jobID;

  // Extra (joined from job)
  String? jobDescription;
  String? jobServiceType;

  Invoice({
    this.invoiceNo,
    this.issuedDate,
    this.dueDate,
    this.status,
    this.jobID,
    this.jobDescription,
    this.jobServiceType,
    this.totalAmount,
  });

  factory Invoice.fromMap(Map<String, dynamic> m) {
    final inv = Invoice();
    inv.invoiceNo = (m['invoiceNo'] ?? '').toString();
    inv.issuedDate = (m['issuedDate'] ?? '').toString();
    inv.dueDate = (m['dueDate'] ?? '').toString();
    inv.status = (m['status'] ?? '').toString();
    final ta = m['totalAmount'];
    inv.totalAmount = ta is num ? ta : num.tryParse(ta?.toString() ?? '');
    inv.jobID = (m['jobID'] ?? '').toString();
    return inv;
  }
}