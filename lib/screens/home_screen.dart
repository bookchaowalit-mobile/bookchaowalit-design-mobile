import 'package:flutter/material.dart';

import '../logic/palette.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _hex = TextEditingController(text: '#6750A4');

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final base = parseHex(_hex.text);
    return Scaffold(
      appBar: AppBar(title: const Text('Design')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('hex-input'),
            controller: _hex,
            decoration: InputDecoration(
              labelText: 'Hex colour',
              hintText: '#RRGGBB or #RGB',
              border: const OutlineInputBorder(),
              errorText: base == null ? 'Enter a colour like #1E88E5' : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (base != null) ...[
            const SizedBox(height: 16),
            Text('Contrast', style: textTheme.titleMedium),
            _ContrastRow(base: base, against: Rgb.white, name: 'white'),
            _ContrastRow(base: base, against: Rgb.black, name: 'black'),
            const SizedBox(height: 16),
            Text('Scale', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final s in scaleFor(base))
              Container(
                constraints: const BoxConstraints(minHeight: 48),
                color: Color(s.color.argb),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${s.label}  ${s.color.hex}',
                  style: TextStyle(color: Color(bestTextOn(s.color).argb)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ContrastRow extends StatelessWidget {
  const _ContrastRow({
    required this.base,
    required this.against,
    required this.name,
  });

  final Rgb base;
  final Rgb against;
  final String name;

  @override
  Widget build(BuildContext context) {
    final ratio = contrastRatio(base, against);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ExcludeSemantics(
        child: CircleAvatar(
          backgroundColor: Color(base.argb),
          child: Text('Aa', style: TextStyle(color: Color(against.argb))),
        ),
      ),
      title: Text('vs $name: ${formatRatio(ratio)}'),
      subtitle: Text('Normal text: ${wcagRating(ratio)}'),
    );
  }
}
