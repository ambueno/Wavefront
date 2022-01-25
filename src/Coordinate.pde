public class Coordinate {
  private int i;
  private int j;
  
  public Coordinate(int i, int j) {
    this.i = i;
    this.j = j;
  }
  
  public int getI() {
    return i;
  }
  
  public int getJ() {
    return j;
  }
  
  @Override
  public int hashCode() {
    final int prime = 23;
    int result = 1;
    result = prime * result + this.i;
    result = result * this.j;
    return result;
  }
  
  @Override
  public boolean equals(Object obj) {
    if (this == obj) return true;
    if (obj == null) return false;
    if (getClass() != obj.getClass()) return false;
    Coordinate other = (Coordinate) obj;
    return (this.i == other.i && this.j == other.j);
  }
}

  
