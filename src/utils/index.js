export function deepClone(source) {
  if (!source && typeof source !== 'object') {
    throw new Error('error arguments', 'deepClone')
  }
  const targetObj = source.constructor === Array ? [] : {}
  Object.keys(source).forEach(keys => {
    if (source[keys] && typeof source[keys] === 'object') {
      targetObj[keys] = deepClone(source[keys])
    } else {
      targetObj[keys] = source[keys]
    }
  })
  return targetObj
}

export function copy(text) {
  const input = document.createElement('input')
  input.readOnly = 'readonly'
  input.value = text
  document.body.appendChild(input)
  input.select()
  input.setSelectionRange(0, input.value.length)
  document.execCommand('Copy')
  document.body.removeChild(input)
}

export const plusXing = (str, frontLen, endLen) => {
  const xing = '...'
  return str.substring(0, frontLen) + xing + str.substring(str.length - endLen)
}

export function timeFormat(dateTime = null, fmt = 'yyyy-mm-dd') {
  if (!dateTime) dateTime = Number(new Date())
  if (dateTime.toString().length === 10) dateTime *= 1000
  const date = new Date(dateTime)
  let ret
  const opt = {
    'y+': date.getFullYear().toString(),
    'm+': (date.getMonth() + 1).toString(),
    'd+': date.getDate().toString(),
    'h+': date.getHours().toString(),
    'M+': date.getMinutes().toString(),
    's+': date.getSeconds().toString()
  }
  for (const k in opt) {
    ret = new RegExp('(' + k + ')').exec(fmt)
    if (ret) {
      fmt = fmt.replace(ret[1], (ret[1].length === 1) ? (opt[k]) : (opt[k].padStart(ret[1].length, '0')))
    }
  }
  return fmt
}
