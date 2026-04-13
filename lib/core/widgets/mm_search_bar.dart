import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class MmSearchBar extends StatefulWidget {
  const MmSearchBar({
    super.key,
    required this.onSearch,
    this.hint,
    this.isLoading = false,
  });

  final ValueChanged<String> onSearch;
  final String? hint;
  final bool isLoading;

  @override
  State<MmSearchBar> createState() => _MmSearchBarState();
}

class _MmSearchBarState extends State<MmSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(DesignTokens.debounceSearch, () {
      widget.onSearch(value);
    });
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    widget.onSearch('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: widget.hint ?? 'Search…',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: DesignTokens.typeMd,
          ),
          prefixIcon: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.search, size: DesignTokens.iconMd),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: DesignTokens.iconMd),
                  onPressed: _clear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: DesignTokens.spaceSm,
          ),
        ),
      ),
    );
  }
}
