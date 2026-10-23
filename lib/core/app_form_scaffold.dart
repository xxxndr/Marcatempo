// Scheletro comune ai form dell'app (Center → ConstrainedBox(360) → Form →
// FilledButton con spinner), duplicato identico in 5 pagine prima di questa
// estrazione. Vedi notes/roadmap.md 3.11 e notes/dev/refactor.md R5.
import 'package:flutter/material.dart';

class AppFormScaffold extends StatelessWidget {
  const AppFormScaffold({
    super.key,
    required this.formKey,
    required this.children,
    required this.isLoading,
    required this.onSubmit,
    required this.submitLabel,
    this.useAutofillGroup = false,
    this.scrollable = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing = const [],
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final bool isLoading;
  final VoidCallback onSubmit;
  final String submitLabel;
  final bool useAutofillGroup;
  final bool scrollable;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          ...children,
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(submitLabel),
          ),
          ...trailing,
        ],
      ),
    );
    final content = useAutofillGroup ? AutofillGroup(child: form) : form;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: scrollable
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: content,
              )
            : Padding(padding: const EdgeInsets.all(24), child: content),
      ),
    );
  }
}
