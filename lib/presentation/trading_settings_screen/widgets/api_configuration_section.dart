import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';
import '../../../core/env_loader.dart';
import '../../../services/bingx_api_service.dart';

class ApiConfigurationSection extends StatefulWidget {
  final String apiKey;
  final String secretKey;
  final int rateLimitCalls;
  final Function(String) onApiKeyChanged;
  final Function(String) onSecretKeyChanged;
  final Function(int) onRateLimitChanged;
  final VoidCallback onTestConnection;
  final VoidCallback onUpdateCredentials;

  const ApiConfigurationSection({
    Key? key,
    required this.apiKey,
    required this.secretKey,
    required this.rateLimitCalls,
    required this.onApiKeyChanged,
    required this.onSecretKeyChanged,
    required this.onRateLimitChanged,
    required this.onTestConnection,
    required this.onUpdateCredentials,
  }) : super(key: key);

  @override
  State<ApiConfigurationSection> createState() =>
      _ApiConfigurationSectionState();
}

class _ApiConfigurationSectionState extends State<ApiConfigurationSection> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();

  bool _isApiKeyVisible = false;
  bool _isSecretKeyVisible = false;
  bool _isLoading = false;
  bool _isValidating = false;
  bool _hasValidKeys = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _loadCurrentKeys();
  }

  @override
  void didUpdateWidget(ApiConfigurationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apiKey != widget.apiKey ||
        oldWidget.secretKey != widget.secretKey) {
      _loadCurrentKeys();
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentKeys() async {
    await EnvLoader.load();

    setState(() {
      _hasValidKeys = EnvLoader.hasBingxCredentials ||
          (widget.apiKey.isNotEmpty && widget.secretKey.isNotEmpty);

      // Only show partial keys if they exist and are valid
      if (_hasValidKeys && widget.apiKey.isNotEmpty) {
        final apiKey = widget.apiKey;
        _apiKeyController.text = apiKey.length > 16
            ? '${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 8)}'
            : apiKey;

        final secretKey = widget.secretKey;
        _secretKeyController.text = secretKey.length > 16
            ? '${secretKey.substring(0, 8)}...${secretKey.substring(secretKey.length - 8)}'
            : secretKey;
      }
    });
  }

  Future<void> _validateAndSaveKeys() async {
    if (_apiKeyController.text.isEmpty || _secretKeyController.text.isEmpty) {
      setState(() {
        _validationError = 'Por favor ingresa ambas claves API';
      });
      return;
    }

    // Don't validate if showing masked keys
    if (_apiKeyController.text.contains('...')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las claves API ya están configuradas correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      final bingxService = BingXApiService();
      await bingxService.saveApiKeys(
          _apiKeyController.text, _secretKeyController.text);

      // Test the API keys by making a simple call
      final balanceTest = await bingxService.getAccountBalance();

      if (balanceTest['code'] == 0 || balanceTest['data'] != null) {
        setState(() {
          _hasValidKeys = true;
          _validationError = null;
        });

        // Update parent widget
        widget.onApiKeyChanged(_apiKeyController.text);
        widget.onSecretKeyChanged(_secretKeyController.text);

        // Mask the keys after successful validation
        final apiKey = _apiKeyController.text;
        final secretKey = _secretKeyController.text;
        _apiKeyController.text =
            '${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 8)}';
        _secretKeyController.text =
            '${secretKey.substring(0, 8)}...${secretKey.substring(secretKey.length - 8)}';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 2.w),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '¡API Keys configuradas exitosamente!',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Ahora verás datos reales de BingX',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Invalid API response');
      }
    } catch (e) {
      setState(() {
        _validationError = 'Error al validar las claves API: ${e.toString()}';
        _hasValidKeys = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_validationError'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  void _clearApiKeys() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar API Keys'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar las claves API configuradas? Esto volverá a mostrar datos de demostración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _isLoading = true;
              });

              try {
                // Clear from SharedPreferences and reset controllers
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('bingx_api_key');
                await prefs.remove('bingx_secret_key');

                setState(() {
                  _apiKeyController.clear();
                  _secretKeyController.clear();
                  _hasValidKeys = false;
                  _validationError = null;
                });

                // Update parent widget
                widget.onApiKeyChanged('');
                widget.onSecretKeyChanged('');

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'API Keys eliminadas. Mostrando datos de demostración.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al limpiar las claves: $e'),
                      backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    ),
                  );
                }
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _hasValidKeys
                        ? AppTheme.lightTheme.colorScheme.tertiary
                            .withOpacity(0.1)
                        : AppTheme.lightTheme.primaryColor
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: _hasValidKeys ? 'verified' : 'vpn_key',
                    color: _hasValidKeys
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuración de BingX API',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _hasValidKeys
                            ? 'Conectado a BingX con datos reales'
                            : 'Configura tus claves para obtener datos reales',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: _hasValidKeys
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasValidKeys)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        SizedBox(width: 1.w),
                        const Text(
                          'ACTIVO',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (!_hasValidKeys || _apiKeyController.text.isEmpty) ...[
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.blue, size: 20),
                        SizedBox(width: 2.w),
                        Text(
                          'Cómo obtener tus API Keys de BingX:',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '1. Ingresa a tu cuenta de BingX\n'
                      '2. Ve a "API Management" en configuración\n'
                      '3. Crea una nueva API Key con permisos de trading\n'
                      '4. Copia y pega aquí tanto la API Key como el Secret',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 3.h),

            // API Key Input
            Text(
              'API Key',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _apiKeyController,
              obscureText: !_isApiKeyVisible,
              enabled: !_isValidating,
              decoration: InputDecoration(
                hintText: _hasValidKeys
                    ? 'API Key configurada'
                    : 'Ingresa tu BingX API Key',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isApiKeyVisible = !_isApiKeyVisible;
                    });
                  },
                  icon: Icon(
                    _isApiKeyVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.6),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppTheme.lightTheme.primaryColor),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secret Key Input
            Text(
              'Secret Key',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _secretKeyController,
              obscureText: !_isSecretKeyVisible,
              enabled: !_isValidating,
              decoration: InputDecoration(
                hintText: _hasValidKeys
                    ? 'Secret Key configurado'
                    : 'Ingresa tu BingX Secret Key',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isSecretKeyVisible = !_isSecretKeyVisible;
                    });
                  },
                  icon: Icon(
                    _isSecretKeyVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.6),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppTheme.lightTheme.primaryColor),
                ),
              ),
            ),

            if (_validationError != null) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 3.h),

            // Action Buttons
            Row(
              children: [
                if (!_hasValidKeys || !_apiKeyController.text.contains('...'))
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isValidating ? null : _validateAndSaveKeys,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isValidating
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Guardar y Validar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                if (_hasValidKeys &&
                    _apiKeyController.text.contains('...')) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _apiKeyController.clear();
                          _secretKeyController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Actualizar Keys'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearApiKeys,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Limpiar Keys',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (_hasValidKeys) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 20),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        '¡Perfecto! Ahora la app mostrará tu balance real y posiciones de BingX. Ve a la pantalla de Portfolio para ver los cambios.',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
