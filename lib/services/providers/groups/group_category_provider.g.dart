// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GroupCategories)
final groupCategoriesProvider = GroupCategoriesProvider._();

final class GroupCategoriesProvider
    extends $AsyncNotifierProvider<GroupCategories, List<GroupCategory>> {
  GroupCategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'groupCategoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupCategoriesHash();

  @$internal
  @override
  GroupCategories create() => GroupCategories();
}

String _$groupCategoriesHash() => r'6185a86d78ca37f5bd813766cc88ded84bad1287';

abstract class _$GroupCategories extends $AsyncNotifier<List<GroupCategory>> {
  FutureOr<List<GroupCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<GroupCategory>>, List<GroupCategory>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<GroupCategory>>, List<GroupCategory>>,
        AsyncValue<List<GroupCategory>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
