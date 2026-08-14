import 'package:aikiglobal/core/data/models/app_content_item.dart';
import 'package:aikiglobal/features/home/home_shell_navigation.dart';
import 'package:aikiglobal/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantiene Perfil al cambiar de vista usuario a admin', () {
    expect(
      resolveHomeShellIndex(
        currentIndex: 2,
        currentItems: _userItems,
        nextItems: _adminItems,
      ),
      4,
    );
  });

  test('mantiene Perfil al cambiar de vista admin a usuario', () {
    expect(
      resolveHomeShellIndex(
        currentIndex: 4,
        currentItems: _adminItems,
        nextItems: _userItems,
      ),
      2,
    );
  });

  test('mantiene el indice actual cuando no hay una pestana equivalente', () {
    expect(
      resolveHomeShellIndex(
        currentIndex: 1,
        currentItems: _userItems,
        nextItems: _adminItems,
      ),
      1,
    );
  });

  test('mapea contenido publicado al modelo requerido por el detalle', () {
    final now = DateTime.utc(2026, 7, 17);
    final item = AppContentItem(
      uuidContentItem: 'content-1',
      tipo: 'meditation',
      titulo: 'Respiración consciente',
      subtitulo: 'Una práctica breve',
      coverPathSupabase: 'covers/content-1.webp',
      status: 'published',
      destacado: true,
      descargable: false,
      duracionSegundos: 900,
      orden: 1,
      createdAt: now,
      updatedAt: now,
    );

    final detailItem = notificationContentItemForDetail(item);

    expect(detailItem.uuidContentItem, 'content-1');
    expect(detailItem.title, 'Respiración consciente');
    expect(detailItem.type, 'Meditación');
    expect(detailItem.duration, '15 min');
    expect(detailItem.imagePath, 'covers/content-1.webp');
    expect(detailItem.description, 'Una práctica breve');
  });
}

const _userItems = [
  AppBottomNavItem(
    label: 'Explorar',
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
  ),
  AppBottomNavItem(
    label: 'Mi espacio',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  AppBottomNavItem(
    label: 'Perfil',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];

const _adminItems = [
  AppBottomNavItem(
    label: 'Contenido',
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
  ),
  AppBottomNavItem(
    label: 'Empresa',
    icon: Icons.business_outlined,
    activeIcon: Icons.business_rounded,
  ),
  AppBottomNavItem(
    label: 'Usuarios',
    icon: Icons.group_outlined,
    activeIcon: Icons.group_rounded,
  ),
  AppBottomNavItem(
    label: 'Avisos',
    icon: Icons.notifications_none_rounded,
    activeIcon: Icons.notifications_rounded,
  ),
  AppBottomNavItem(
    label: 'Perfil',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];
