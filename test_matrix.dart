import 'package:matrix/matrix.dart';
void main() {
  Client c = Client('test');
  c.waitForRoomInSync('some_id');
}
