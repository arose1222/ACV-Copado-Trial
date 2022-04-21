import { LightningElement, api, wire, track } from 'lwc';
import getAudioLink from '@salesforce/apex/EngineAudioPlayerComponent.getAudioLink';

export default class EngineAudioPlayer extends LightningElement {
    @api recordId;
    @wire(getAudioLink, {caseId: '$recordId'}) audioLink;
}