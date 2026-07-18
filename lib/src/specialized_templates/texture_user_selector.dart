part of '../specialized_templates.dart';

/// A texture source shown by Blender's Properties texture-user template.
@immutable
class BlenderTextureUser {
  const BlenderTextureUser({
    required this.id,
    required this.name,
    this.textureName,
    this.category,
    this.icon = BlenderGlyph.texture,
    this.enabled = true,
  });

  final String id;
  final String name;
  final String? textureName;
  final String? category;
  final BlenderGlyph icon;
  final bool enabled;
}

/// Blender's texture-user menu plus the adjacent Properties-tab jump button.
class BlenderTextureUserSelector extends StatelessWidget {
  const BlenderTextureUserSelector({
    super.key,
    required this.users,
    this.selectedId,
    this.onChanged,
    this.onShowTexture,
    this.showTextureEnabled = true,
    this.showTextureDisabledTooltip = 'No texture user available',
    this.hasTexture = true,
    this.inTextureProperties = false,
    this.noUsersLabel = 'No textures in context',
  });

  final List<BlenderTextureUser> users;
  final String? selectedId;
  final ValueChanged<BlenderTextureUser>? onChanged;
  final VoidCallback? onShowTexture;
  final bool showTextureEnabled;
  final String showTextureDisabledTooltip;
  final bool hasTexture;
  final bool inTextureProperties;
  final String noUsersLabel;

  List<BlenderMenuItem<String>> _menuItems() {
    final items = <BlenderMenuItem<String>>[];
    String? lastCategory;
    for (final user in users) {
      final category = user.category;
      if (category != null && category != lastCategory) {
        items.add(
          BlenderMenuItem<String>(
            value: '__texture_category_$category',
            label: category,
            enabled: false,
          ),
        );
        lastCategory = category;
      }
      items.add(
        BlenderMenuItem<String>(
          value: user.id,
          label: user.textureName == null
              ? user.name
              : '${user.name} - ${user.textureName}',
          icon: BlenderIcon(user.icon, size: 14),
          enabled: user.enabled,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Text(
        noUsersLabel,
        style: BlenderTheme.of(context).textTheme.caption.copyWith(
          color: BlenderTheme.of(context).colors.foregroundMuted,
        ),
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderDropdown<String>(
            value: selectedId ?? users.first.id,
            items: _menuItems(),
            selectedLabel: () {
              final activeId = selectedId ?? users.first.id;
              for (final user in users) {
                if (user.id == activeId) return user.name;
              }
              return users.first.name;
            }(),
            onChanged: onChanged == null
                ? null
                : (id) {
                    for (final user in users) {
                      if (user.id == id) {
                        onChanged!(user);
                        return;
                      }
                    }
                  },
          ),
        ),
        if (onShowTexture != null &&
            hasTexture &&
            !inTextureProperties) ...<Widget>[
          const SizedBox(width: 4),
          BlenderIconButton(
            glyph: BlenderGlyph.properties,
            onPressed: showTextureEnabled ? onShowTexture : null,
            enabled: showTextureEnabled,
            tooltip: showTextureEnabled
                ? 'Show texture in Texture tab'
                : showTextureDisabledTooltip,
            size: 24,
          ),
        ],
      ],
    );
  }
}
