// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_invitation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeGroupInvitation)
final activeGroupInvitationProvider = ActiveGroupInvitationProvider._();

final class ActiveGroupInvitationProvider extends $FunctionalProvider<
        AsyncValue<GroupInvitation?>,
        GroupInvitation?,
        FutureOr<GroupInvitation?>>
    with $FutureModifier<GroupInvitation?>, $FutureProvider<GroupInvitation?> {
  ActiveGroupInvitationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeGroupInvitationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeGroupInvitationHash();

  @$internal
  @override
  $FutureProviderElement<GroupInvitation?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GroupInvitation?> create(Ref ref) {
    return activeGroupInvitation(ref);
  }
}

String _$activeGroupInvitationHash() =>
    r'387eb31243d944ac0e49394e6cc9ad0dd3868ed0';
