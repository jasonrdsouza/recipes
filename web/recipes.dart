import 'dart:html';
import 'package:markdown/markdown.dart';

void main() {
  print('Recipe loaded!');

  fetchElementsById('ingredient').forEach((e) => renderElementContentsAsHtml(e));
  fetchElementsById('step').forEach((e) => renderElementContentsAsHtml(e));
  fetchElementsById('note').forEach((e) => renderElementContentsAsHtml(e));
  fetchElementsById('based').forEach((e) => renderElementContentsAsHtml(e));

  fetchElementsById('step').forEach((element) {
    element.onClick.listen((event) {
      if (element.classes.contains('highlight')) {
        element.classes.remove('highlight');
      } else {
        unhighlightall();
        element.classes.add('highlight');
      }
    });
  });
}

List<HtmlElement> fetchElementsById(String id) {
  return querySelectorAll('#${id}');
}

void unhighlightall() {
  querySelectorAll('.highlight').forEach((element) => element.classes.remove('highlight'));
}

class PermissiveUriPolicy implements UriPolicy {
  @override
  bool allowsUri(String uri) {
    return true;
  }
}

final NodeValidatorBuilder _validator = NodeValidatorBuilder.common()..allowNavigation(PermissiveUriPolicy());

void renderElementContentsAsHtml(HtmlElement element) {
  var elementText = element.text;

  if (elementText != null) {
    var renderedMarkdown = markdownToHtml(elementText);
    element.setInnerHtml(renderedMarkdown.substring(3, renderedMarkdown.length - 5), validator: _validator);
  }
}
