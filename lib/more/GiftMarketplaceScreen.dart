import 'package:flutter/material.dart';

class GiftMarketplaceScreen extends StatelessWidget {
  const GiftMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(6, (i) => sampleItem(i));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: ListView(
            children: [
              const SizedBox(height: 10),

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.card_giftcard_rounded, color: Color(0xFF8A57E6)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gift & Experience Marketplace',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'AI-recommended gifts and experiences for your partner based on your relationship',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 14),

              // AI Recommendation banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF7EBFF), Color(0xFFF3EAFD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.purple.withOpacity(0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEEE0FF),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF8A57E6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Recommendation for You',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Based on your partner\'s recent mood and your upcoming anniversary, we recommend the "Personalized Photo Book" or "Weekend Getaway".',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text('View Recommended Gifts'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search & Filters
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search gifts and experiences...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF6F3FA),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: 'All',
                            items:
                                const ['All', 'Personalized', 'Experience']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (_) {},
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: () {},
                          child: const Icon(Icons.filter_alt_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Recommended header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recommended for You',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  Text('8 items', style: TextStyle(color: Colors.black45)),
                ],
              ),
              const SizedBox(height: 12),

              // Cards
              ...items.map(
                (it) => Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: GiftCard(item: it),
                ),
              ),

              const SizedBox(height: 20),

              // Info Section
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'How Cuplix Gift Marketplace Works',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _InfoColumn(
                          icon: Icons.auto_awesome,
                          title: 'AI-Powered Recommendations',
                          subtitle:
                              'Our AI suggests the most meaningful gifts for your partner',
                        ),
                        _InfoColumn(
                          icon: Icons.shopping_cart,
                          title: 'Easy Shopping',
                          subtitle:
                              'Browse and purchase securely through our platform',
                        ),
                        _InfoColumn(
                          icon: Icons.favorite,
                          title: 'Thoughtful Gifting',
                          subtitle:
                              'Surprise your partner with personalized gestures',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static GiftItem sampleItem(int i) => GiftItem(
    title: i % 2 == 0 ? 'Personalized Photo Book' : 'Spa Day for Two',
    price: i % 2 == 0 ? '\$29.99' : '\$149.99',
    rating: i % 2 == 0 ? 4.8 : 4.9,
    tags:
        i % 2 == 0
            ? ['Anniversary', 'Memory', 'Custom']
            : ['Relaxation', 'Romance', 'Luxury'],
    imageUrl: 'https://picsum.photos/seed/gift$i/800/360',
    isPersonalized: i % 2 == 0,
  );
}

class GiftItem {
  final String title;
  final String price;
  final double rating;
  final List<String> tags;
  final String imageUrl;
  final bool isPersonalized;

  GiftItem({
    required this.title,
    required this.price,
    required this.rating,
    required this.tags,
    required this.imageUrl,
    this.isPersonalized = false,
  });
}

class GiftCard extends StatelessWidget {
  final GiftItem item;

  const GiftCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: 16 / 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: const Color(0xFFF2ECEF));
                    },
                  ),
                  if (item.isPersonalized)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A57E6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Personalized',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Custom photo book of your favorite memories together',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      item.tags
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F1F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 14),

                // ✅ price + gradient button (overflow-safe)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.open_in_new_outlined),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8A57E6), Color(0xFFEA6FA4)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.card_giftcard_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Flexible(
                            child: Text(
                              'Send to Your Partner',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoColumn({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFF2E6FF),
            child: Icon(icon, color: const Color(0xFF8A57E6)),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
