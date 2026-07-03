import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import 'dart:io';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isGenerating = false;
  
  // Patient data
  String _name = 'Patient';
  String _surname = '';
  String _gender = '-';
  String _dob = '-';
  String _height = '-';
  String _weight = '-';
  String _age = '-';
  
  // Last transfusion
  String _lastTransfusionDate = 'No data';

  static const Color primaryRed = Color.fromARGB(255, 183, 38, 38);

  @override
  void initState() {
    super.initState();
    _loadPatientData();
    _loadLastTransfusionDate(); 
  }

  Future<void> _loadPatientData() async {
    final sp = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _name = sp.getString('name') ?? 'Patient';
        _surname = sp.getString('surname') ?? '';
        _gender = sp.getString('gender') ?? '-';
        _dob = sp.getString('dob') ?? '-';
        _height = sp.getString('height') ?? '-';
        _weight = sp.getString('weight') ?? '-';

        if (_dob.isNotEmpty && _dob != '-') {
          try {
            final parts = _dob.split('/');
            if (parts.length >= 3) {
              final birthYear = int.parse(parts[2]);
              _age = (DateTime.now().year - birthYear).toString();
            }
          } catch (e) {
            _age = '-';
          }
        }
      });
    }
  }

  Future<void> _loadLastTransfusionDate() async {
    final sp = await SharedPreferences.getInstance();
    final keys = sp.getKeys();
    DateTime? latestDate;
    
    for (String key in keys) {
      if (key.startsWith('events_')) {
        List<String>? events = sp.getStringList(key);
        
        if (events != null && events.any((e) => e.contains('Transfusion'))) {
          String dateStr = key.substring(7); 
          try {
            DateTime eventDate = DateTime.parse(dateStr);
            
            DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
            if (eventDate.isBefore(today) || eventDate.isAtSameMomentAs(today)) {
              if (latestDate == null || eventDate.isAfter(latestDate)) {
                latestDate = eventDate;
              }
            }
          } catch (e) {
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        if (latestDate != null) {
          _lastTransfusionDate = DateFormat('d MMM yyyy').format(latestDate);
        } else {
          _lastTransfusionDate = 'No data';
        }
      });
    }
  }

  Future<void> _generateAndSharePDF() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                    level: 0,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Thala Buddy', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                        pw.Text('Clinical Report', style: const pw.TextStyle(fontSize: 24, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  pw.Text('Patient Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildPdfInfoRow('Full Name:', '$_name $_surname'.trim()),
                            pw.SizedBox(height: 8),
                            _buildPdfInfoRow('Date of Birth:', _dob),
                            pw.SizedBox(height: 8),
                            _buildPdfInfoRow('Age:', '$_age years'),
                          ]
                        )
                      ),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildPdfInfoRow('Gender:', _gender),
                            pw.SizedBox(height: 8),
                            _buildPdfInfoRow('Height:', '$_height cm'),
                            pw.SizedBox(height: 8),
                            _buildPdfInfoRow('Weight:', '$_weight kg'),
                          ]
                        )
                      ),
                    ]
                  ),
                  
                  pw.SizedBox(height: 15),
                  pw.Text('Date of Report: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                  pw.SizedBox(height: 30),

                  pw.Text('Last 30 Days Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                  
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      _buildPdfTableRow('Average Effort Index', '4.2 pts', PdfColors.orange700),
                      _buildPdfTableRow('Average HRR', '85 bpm', PdfColors.green700),
                      _buildPdfTableRow('Days with Fatigue Alert', '4 days', PdfColors.red700),
                      _buildPdfTableRow('Last Transfusion', _lastTransfusionDate, PdfColors.black),
                    ],
                  ),
                  
                  pw.SizedBox(height: 40),
                  
                  pw.Text('Doctor\'s Notes:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 10),
                    height: 100,
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                    ),
                  ),
                  
                  pw.Spacer(),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text('Generated securely by Thala Buddy App', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  )
                ],
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/ThalaBuddy_ClinicalReport.pdf');
      await file.writeAsBytes(await pdf.save());

      final xFile = XFile(file.path);
      
      await Share.shareXFiles([xFile]);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(label, style: pw.TextStyle(color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 8),
        pw.Text(value),
      ],
    );
  }

  pw.TableRow _buildPdfTableRow(String label, String value, PdfColor valueColor) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 14)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: valueColor)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clinical Report', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            const Text('Export your vitals and symptom history for your hematologist.', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text('Last 30 Days Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildReportRow('Average Effort Index:', '4.2 pts', Colors.orange.shade700),
                  const SizedBox(height: 12),
                  _buildReportRow('Average HRR:', '85 bpm', Colors.green.shade700),
                  const SizedBox(height: 12),
                  _buildReportRow('Days with Fatigue Alert:', '4 days', Colors.red.shade700),
                  const SizedBox(height: 12),
                  _buildReportRow('Last Transfusion:', _lastTransfusionDate, Colors.black87),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateAndSharePDF,
                icon: _isGenerating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  _isGenerating ? 'Generating...' : 'Export as PDF & Share', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed, 
                  disabledBackgroundColor: primaryRed.withOpacity(0.5), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}