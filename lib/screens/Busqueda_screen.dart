import 'package:flutter/material.dart';
import 'package:proyecto_libreria/screens/custom_navbar.dart';
import 'package:proyecto_libreria/database/Busqueda_db.dart';
import 'package:proyecto_libreria/screens/Pdfview_screen.dart';

class Busqueda_screen extends StatefulWidget {
  final int? selectedCategoryId;

  const Busqueda_screen({Key? key, this.selectedCategoryId}) : super(key: key);

  @override
  _Busqueda_screenState createState() => _Busqueda_screenState();
}

class _Busqueda_screenState extends State<Busqueda_screen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  int? _selectedCategoryId;

  List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Ficción', 'image': 'lib/assets/ficción.jpg'},
    {'id': 2, 'name': 'Ciencia', 'image': 'lib/assets/ciencia.jpg'},
    {'id': 3, 'name': 'Historia', 'image': 'lib/assets/historia.jpg'},
    {'id': 4, 'name': 'Filosofía', 'image': 'lib/assets/filosofia.jpg'},
    {'id': 5, 'name': 'Arte', 'image': 'lib/assets/arte.jpg'},
    {'id': 6, 'name': 'Misterio', 'image': 'lib/assets/misterio.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _searchBooks();
  }

  void _searchBooks() async {
    String query = _searchController.text.trim();
    if (query.isNotEmpty || _selectedCategoryId != null) {
      var results = await LibroDB().searchBooks(
        query,
        categoryId: _selectedCategoryId,
      );
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _selectCategory(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _searchBooks();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B837D),
        title: const Text('Búsqueda de Libros'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFCAD9DC),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E8585),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          _searchBooks();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar libros...',
                          hintStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: _clearSearch,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _searchController.text.isEmpty && _selectedCategoryId == null
                  ? Column(
                      children: [
                        const Text(
                          'Explorar categorías',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return categoryButton(
                              categories[index]['id'],
                              categories[index]['name'],
                              categories[index]['image'],
                            );
                          },
                        ),
                      ],
                    )
                  : _selectedCategoryId != null
                      ? Column(
                          children: [
                            const Text(
                              'Categoría Seleccionada',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            categoryButton(
                              _selectedCategoryId!,
                              categories
                                  .firstWhere((cat) =>
                                      cat['id'] == _selectedCategoryId)['name']
                                  .toString(),
                              categories
                                  .firstWhere((cat) =>
                                      cat['id'] == _selectedCategoryId)['image']
                                  .toString(),
                            ),
                          ],
                        )
                      : Container(),
              const SizedBox(height: 20),
              _searchResults.isEmpty
                  ? const Center(child: Text("No se encontraron libros"))
                  : Column(
                      children: _searchResults.map<Widget>((book) {
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.network(
                                  book['imagen_libro'] ??
                                      'https://via.placeholder.com/150',
                                  width: 90,
                                  height: 130,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 90,
                                      height: 130,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book['titulo'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF083332),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book['sinopsis'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF19ADA6),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Abriendo libro: ${book['titulo']}'),
                                            ),
                                          );
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PDFViewerPage(
                                                assetPath:
                                                    book['pdf_libro'] ??
                                                        'lib/assets/el_principito.pdf',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Leer",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget categoryButton(int categoryId, String categoryName, String assetPath) {
    return GestureDetector(
      onTap: () {
        _selectCategory(categoryId);
      },
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(5),
            child: Text(
              categoryName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
