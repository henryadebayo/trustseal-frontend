import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:trustseal_app/core/services/vault_service.dart';

class VaultUploadScreen extends StatefulWidget {
  const VaultUploadScreen({super.key});

  @override
  State<VaultUploadScreen> createState() => _VaultUploadScreenState();
}

class _VaultUploadScreenState extends State<VaultUploadScreen>
    with TickerProviderStateMixin {
  final VaultService _vaultService = VaultService();
  final TextEditingController _descriptionController = TextEditingController();

  dynamic _selectedFile; // Can be File or _MockFile
  String? _selectedReceiverId;
  List<Map<String, dynamic>> _receivers = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _uploadStatus;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
    _loadReceivers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadReceivers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final receivers = await _vaultService.getAvailableReceivers();
      setState(() {
        _receivers = receivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load receivers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectFile() async {
    try {
      // For web, we'll use a simpler approach
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true, // Important for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        setState(() {
          if (file.bytes != null) {
            // Web platform
            _selectedFile = _MockFile(file.bytes!, file.name);
          } else if (file.path != null) {
            // Mobile platform
            _selectedFile = File(file.path!);
          }
          _uploadStatus = null;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: ${file.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('File picker error: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select file: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _selectedReceiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file and receiver'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Encrypting file...';
    });

    try {
      final result = await _vaultService.uploadToVault(
        file: _selectedFile!,
        receiverId: _selectedReceiverId!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      setState(() {
        _uploadStatus = 'Upload successful!';
        _isUploading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Upload Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File uploaded and encrypted successfully!'),
              const SizedBox(height: 8),
              Text('Transaction ID: ${result['transactionId']}'),
              const SizedBox(height: 8),
              Text('IPFS Hash: ${result['ipfsHash']}'),
              const SizedBox(height: 8),
              Text('IPFS URL: ${result['ipfsUrl']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text('Upload Another'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed: $e';
        _isUploading = false;
      });

      // Detailed error logging
      print('❌ Upload Error Details:');
      print('   Error Type: ${e.runtimeType}');
      print('   Error Message: $e');
      print('   Stack Trace: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload failed'),
              const SizedBox(height: 4),
              Text(e.toString(), style: const TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 7),
          action: SnackBarAction(
            label: 'Details',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Upload Error'),
                  content: SingleChildScrollView(
                    child: Text(
                      'Error Type: ${e.runtimeType}\n\n'
                      'Error Message: $e\n\n'
                      'Check browser console for backend response details.',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _selectedReceiverId = null;
      _descriptionController.clear();
      _uploadStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Vault Upload'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF1E40AF),
                  Color(0xFF1E293B),
                ],
                stops: [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.security,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Secure Document Vault',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload sensitive documents with military-grade encryption. Your files are protected with hybrid encryption and can only be accessed by authorized auditors.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // File Selection
                    _buildFileSelectionCard(),

                    const SizedBox(height: 20),

                    // Receiver Selection
                    _buildReceiverSelectionCard(),

                    const SizedBox(height: 20),

                    // Description
                    _buildDescriptionCard(),

                    const SizedBox(height: 24),

                    // Upload Button
                    _buildUploadButton(),

                    const SizedBox(height: 20),

                    // Status
                    if (_uploadStatus != null) _buildStatusCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Select File',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_selectedFile != null)
                TextButton.icon(
                  onPressed: _isUploading
                      ? null
                      : () {
                          setState(() {
                            _selectedFile = null;
                          });
                        },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white70,
                    size: 20,
                  ),
                  label: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isUploading ? null : _selectFile,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedFile == null) ...[
                    Icon(Icons.cloud_upload, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to select a file',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    // File Preview Section
                    _buildFilePreview(),
                    const SizedBox(height: 12),
                    // File Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.file_present,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getFileName(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getFileSize(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    final fileName = _getFileName().toLowerCase();

    // Image preview for image files
    if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif') ||
        fileName.endsWith('.webp')) {
      return FutureBuilder<Uint8List>(
        future: _selectedFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                snapshot.data!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildGenericFileIcon();
                },
              ),
            );
          }
          return _buildLoadingPreview();
        },
      );
    }

    // PDF or document preview
    return _buildGenericFileIcon();
  }

  Widget _buildGenericFileIcon() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, color: Colors.white, size: 56),
            const SizedBox(height: 8),
            Text(
              _getFileExtension().toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPreview() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  String _getFileName() {
    if (_selectedFile == null) return '';
    return _selectedFile!.path.split('/').last;
  }

  String _getFileExtension() {
    final fileName = _getFileName();
    if (fileName.contains('.')) {
      return fileName.split('.').last;
    }
    return 'file';
  }

  String _getFileSize() {
    if (_selectedFile == null) return '';

    try {
      final size = _selectedFile!.lengthSync();
      if (size < 1024) {
        return '$size B';
      } else if (size < 1024 * 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  Widget _buildReceiverSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Auditor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            DropdownButtonFormField<String>(
              value: _selectedReceiverId,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              items: _receivers.map((receiver) {
                return DropdownMenuItem<String>(
                  value: receiver['id'],
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  receiver['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  receiver['email'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isUploading
                  ? null
                  : (value) {
                      print('Receiver selected: $value'); // Debug print
                      setState(() {
                        _selectedReceiverId = value;
                      });
                    },
              hint: const Text(
                'Choose an auditor',
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description (Optional)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            enabled: !_isUploading,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Add a description for this document...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              // Debug print to check if field is responsive
              print('Description changed: $value');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _uploadFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3B82F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: _isUploading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Encrypting & Uploading...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Upload to Secure Vault',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _uploadStatus!.contains('successful')
            ? Colors.green.withOpacity(0.2)
            : _uploadStatus!.contains('failed')
            ? Colors.red.withOpacity(0.2)
            : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _uploadStatus!.contains('successful')
              ? Colors.green
              : _uploadStatus!.contains('failed')
              ? Colors.red
              : Colors.blue,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _uploadStatus!.contains('successful')
                ? Icons.check_circle
                : _uploadStatus!.contains('failed')
                ? Icons.error
                : Icons.info,
            color: _uploadStatus!.contains('successful')
                ? Colors.green
                : _uploadStatus!.contains('failed')
                ? Colors.red
                : Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _uploadStatus!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Mock file class for web compatibility
class _MockFile {
  final Uint8List _bytes;
  final String _name;

  _MockFile(this._bytes, this._name);

  String get path => _name;

  Future<Uint8List> readAsBytes() async {
    return _bytes;
  }

  Uint8List readAsBytesSync() {
    return _bytes;
  }

  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(_bytes);
  }

  String readAsStringSync({Encoding encoding = utf8}) {
    return encoding.decode(_bytes);
  }

  Stream<Uint8List> openRead([int? start, int? end]) async* {
    yield _bytes;
  }

  Future<int> length() async {
    return _bytes.length;
  }

  int lengthSync() {
    return _bytes.length;
  }

  Future<bool> exists() async {
    return true;
  }

  bool existsSync() {
    return true;
  }
}
