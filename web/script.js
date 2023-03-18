const getEl = function(id) { return document.getElementById(id) }
let recorded = false
let chartrecord = {}
window.addEventListener('message', (message) => {
    let event = message.data;
    if (event.show) {
        getEl('evidence').style.opacity = '1.0'
        getEl('evidenceid').innerHTML = event.data.evidenceid
        getEl('officer').innerHTML = event.data.submit_by
        getEl('location').innerHTML = event.data.location
        getEl('time').innerHTML = event.data.time
        getEl('occupation').innerHTML = event.data.occupation
        getEl('type').innerHTML = event.data.type
        getEl('suspect').innerHTML = event.data.person
        getEl('dateofbirth').innerHTML = event.data.dateofbirth
        getEl('occupation').innerHTML = event.data.occupation
        getEl('evidence_recovered_by').innerHTML = event.data.recoveredby
        getEl('victim_name').innerHTML = event.data.victim
        getEl('case').innerHTML = event.data.case
        getEl('description_evidence').innerHTML = event.data.description_evidence
        getEl('description_offense').innerHTML = event.data.description_offense
        getEl('remarks').innerHTML = event.data.remarks
        getEl('sealed_time').innerHTML = event.data.sealed_time
        getEl('foundin').innerHTML = event.data.plate && 'Vehicle' || ''
        getEl('found').innerHTML = event.data.plate || ''
        console.log(event.data.serialid)
        getEl('moreinfo').style.display = event.data.serialid && 'block' || 'none'
        getEl('iteminfo').innerHTML = event.data.serialid && event.data.name || ''
        getEl('serialid').innerHTML = event.data.serialid || ''

    }

})

document.addEventListener("keydown", (event) => {
    if (event.keyCode == 27 || event.keyCode === 36 || event.keyCode === 8) {
        getEl('evidence').style.opacity = '0.0'
        var xhr = new XMLHttpRequest();
        xhr.open("POST", 'https://renzu_evidence/close', true)
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send()
    }
});