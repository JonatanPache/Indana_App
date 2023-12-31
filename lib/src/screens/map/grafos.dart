class Grafo {
  Map<int, List<Conexion>> nodos = {};

  void agregarNodo(int nodo) {
    nodos[nodo] = [];
  }

  void agregarConexion(int inicio, int fin, int peso) {
    nodos[inicio]!.add(Conexion(fin, peso));
    nodos[fin]!.add(Conexion(inicio, peso));
  }

  List<int> dijkstra(int inicio, int fin) {
    Map<int, int> distancias = {};
    Map<int, int> padres = {};
    List<int> nodosVisitados = [];

    for (var nodo in nodos.keys) {
      distancias[nodo] = 9999999;
    }

    distancias[inicio] = 0;

    while (nodosVisitados.length < nodos.length) {
      int nodoActual =
          _nodoNoVisitadoConMenorDistancia(distancias, nodosVisitados);
      nodosVisitados.add(nodoActual);

      for (var conexion in nodos[nodoActual]!) {
        int distanciaDesdeInicio = distancias[nodoActual]! + conexion.peso;
        if (distanciaDesdeInicio < distancias[conexion.nodo]!) {
          distancias[conexion.nodo] = distanciaDesdeInicio;
          padres[conexion.nodo] = nodoActual;
        }
      }
    }

    return _construirCamino(padres, inicio, fin);
  }

  int _nodoNoVisitadoConMenorDistancia(
      Map<int, int> distancias, List<int> nodosVisitados) {
    int minDistancia = 9999999;
    int nodoMinimo = -1;

    for (var nodo in nodos.keys) {
      if (!nodosVisitados.contains(nodo) && distancias[nodo]! < minDistancia) {
        minDistancia = distancias[nodo]!;
        nodoMinimo = nodo;
      }
    }

    return nodoMinimo;
  }

  List<int> _construirCamino(Map<int, int> padres, int inicio, int fin) {
    List<int> camino = [fin];
    int nodoActual = fin;

    while (padres.containsKey(nodoActual) && nodoActual != inicio) {
      nodoActual = padres[nodoActual]!;
      camino.insert(0, nodoActual);
    }

    return camino;
  }
}

class Conexion {
  int nodo;
  int peso;

  Conexion(this.nodo, this.peso);
}
