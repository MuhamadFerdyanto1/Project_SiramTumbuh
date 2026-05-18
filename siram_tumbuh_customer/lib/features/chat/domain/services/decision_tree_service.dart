class DecisionTreeNode {
  final String id;
  final String question;
  final Map<String, String> options; // Label -> Next Node ID or Recommendation

  DecisionTreeNode({
    required this.id,
    required this.question,
    required this.options,
  });
}

class DecisionTreeService {
  final Map<String, DecisionTreeNode> _nodes = {
    'root': DecisionTreeNode(
      id: 'root',
      question: 'Berapa perkiraan luas lahan yang ingin Anda tanami?',
      options: {
        'Kecil (<10m2)': 'low_budget_check',
        'Sedang (10-50m2)': 'maintenance_check',
        'Luas (>50m2)': 'purpose_check',
      },
    ),
    'low_budget_check': DecisionTreeNode(
      id: 'low_budget_check',
      question: 'Berapa budget maksimal yang Anda siapkan?',
      options: {
        '< 1 Juta': 'REC: Paket Vertical Garden (Sangat hemat lahan dan biaya).',
        '> 1 Juta': 'REC: Paket Mini Garden Luxe (Cocok untuk area teras/balkon).',
      },
    ),
    'maintenance_check': DecisionTreeNode(
      id: 'maintenance_check',
      question: 'Apakah Anda punya banyak waktu untuk merawat tanaman?',
      options: {
        'Ya (Hobi)': 'REC: Paket Flower Bed Mix (Beragam bunga warna-warni).',
        'Tidak (Sibuk)': 'REC: Paket Tropical Low Maintenance (Tanaman tahan banting).',
      },
    ),
    'purpose_check': DecisionTreeNode(
      id: 'purpose_check',
      question: 'Apa tujuan utama pembuatan taman ini?',
      options: {
        'Estetika': 'REC: Paket Landscape Premium (Desain mewah & artistik).',
        'Produktif': 'REC: Paket Edible Garden (Kebun sayur & buah di rumah).',
      },
    ),
  };

  DecisionTreeNode? getNode(String id) => _nodes[id];

  bool isRecommendation(String result) => result.startsWith('REC:');
}
