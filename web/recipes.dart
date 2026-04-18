import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:markdown/markdown.dart';

void main() {
  print('Recipe loaded!');

  fetchElementsById('ingredient').forEach((e) => renderElementContentsAsHtml(e));
  fetchElementsById('step').forEach((e) => renderElementContentsAsHtml(e));
  fetchElementsById('note').forEach((e) => renderElementContentsAsHtml(e));
  fetchElementsById('based').forEach((e) => renderElementContentsAsHtml(e));

  for (var element in fetchElementsById('step')) {
    element.addEventListener(
        'click',
        (Event event) {
          if (element.classList.contains('highlight')) {
            element.classList.remove('highlight');
          } else {
            unhighlightAll();
            element.classList.add('highlight');
          }
        }.toJS);
  }
}

List<HTMLElement> fetchElementsById(String id) {
  var nodeList = document.querySelectorAll('#$id');
  return [
    for (var i = 0; i < nodeList.length; i++)
      nodeList.item(i)! as HTMLElement
  ];
}

void unhighlightAll() {
  var highlighted = document.querySelectorAll('.highlight');
  for (var i = 0; i < highlighted.length; i++) {
    (highlighted.item(i)! as HTMLElement).classList.remove('highlight');
  }
}

void renderElementContentsAsHtml(HTMLElement element) {
  var elementText = element.textContent;

  if (elementText != null) {
    var renderedMarkdown = markdownToHtml(elementText);
    element.innerHTML = renderedMarkdown.substring(3, renderedMarkdown.length - 5).toJS;
  }
}
