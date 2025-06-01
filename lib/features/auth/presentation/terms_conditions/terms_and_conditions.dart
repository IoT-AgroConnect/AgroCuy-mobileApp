import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB16546),
        title: const Text(
          'Términos y Condiciones',
          style: TextStyle(color: Color(0xFFFDF6E4)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFDF6E4)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: const Text(
            '''
Bienvenido a AgroCuy

Estos términos y condiciones describen las reglas y regulaciones para el uso de la plataforma de AgroCuy.

Al acceder a esta aplicación asumimos que aceptas estos términos. No continúes utilizando AgroCuy si no estás de acuerdo con ellos.

1. Uso de Cookies
Utilizamos cookies para mejorar tu experiencia. Al usar AgroCuy, aceptas su uso según nuestra Política de Privacidad.

2. Propiedad Intelectual
A menos que se indique lo contrario, AgroCuy y/o sus licenciantes poseen todos los derechos sobre el contenido de la plataforma. Puedes usarlo solo con fines personales y no comerciales.

No está permitido:
- Reproducir, copiar o republicar contenido sin autorización.
- Vender, alquilar o sublicenciar material de AgroCuy.
- Redistribuir contenido.

3. Comentarios
Los usuarios pueden dejar comentarios u opiniones. AgroCuy no se responsabiliza por ellos, pero podrá eliminarlos si son ofensivos, ilegales o inapropiados.

Al comentar, declaras que:
- Tienes derecho a publicar el contenido.
- No infringes derechos de terceros.
- No contiene lenguaje ofensivo ni ilegal.
- No tiene fines comerciales ilícitos.

4. Enlaces y terceros
Organizaciones pueden enlazar a AgroCuy solo si no generan confusión o asociación engañosa con nuestra marca. Nos reservamos el derecho de eliminar enlaces sin previo aviso.

5. iFrames
No puedes usar frames que alteren la presentación de AgroCuy sin permiso.

6. Contenido de terceros
No somos responsables por contenido en sitios externos que enlacen con AgroCuy.

7. Cambios en los términos
Podemos modificar estos términos sin previo aviso. Te recomendamos revisarlos periódicamente.

8. Limitación de responsabilidad
No garantizamos que el contenido sea exacto o esté actualizado. No nos hacemos responsables por pérdidas o daños derivados del uso de AgroCuy.

9. Legislación aplicable
Este acuerdo se rige por las leyes de Perú. Al usar AgroCuy, aceptas estas condiciones.

Gracias por confiar en AgroCuy.
            ''',
            style: TextStyle(fontSize: 16, color: Color(0xFF5A3B2F), height: 1.6),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
