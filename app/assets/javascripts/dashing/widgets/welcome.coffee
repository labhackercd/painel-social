$(document).ready ->
  colors = [
    '#f58559'
    '#f9a43e'
    '#67bf74'
    '#59a2be'
    '#2093cd'
    '#ad62a7'
  ]
  $('.icon').each ->
    random = Math.floor(Math.random() * colors.length)
    $(this).css 'background-color', colors[random]
    return
  return