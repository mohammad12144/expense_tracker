class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String thumbnail;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
        price: (json['price'] as num).toDouble(),
        thumbnail: (json['thumbnail'] as String?) ?? '',
      );
}