class ElementTask {
  final String name;
  final bool isDone;
  final int? frequency;

  ElementTask(this.name, this.isDone, {this.frequency});

  @override
  String toString() {
    return 'ElementTask{name: $name, isDone: $isDone, frequency: $frequency}';
  }
}
