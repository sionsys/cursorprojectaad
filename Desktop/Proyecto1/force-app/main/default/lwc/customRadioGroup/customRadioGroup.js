import { LightningElement, api } from 'lwc';

export default class CustomRadioGroup extends LightningElement {
    @api label;
    @api options;
    onHoverMessage;
    
    handleClick(e){
        this.value = e.target.value;
        this.dispatchEvent( new CustomEvent('change', { detail: {
            value: this.value 
        } }));
    }

    @api reset(){
        this.template.querySelector('input:checked').checked = false;
    }

    handleMouseOver = (event) => {
        const hoveredItem = this.options.find(e => e.value === event.target.parentNode.dataset.value);
        if(!hoveredItem || !hoveredItem.onhover) return;
        this.onHoverMessage = hoveredItem.onhover;
        const cmp = this.template.querySelector('[data-value="'+ event.target.parentNode.dataset.value + '"]').getBoundingClientRect(),
			right = cmp.right, left = cmp.left, top = cmp.top;

		this.template.querySelector('c-cpq-configurator-popover').setPopoverPosition(right - (right - left) / 2, top, { x: '-50%', y: '-120%' });
		this.template.querySelector('c-cpq-configurator-popover').show();
	}

    handleMouseOverOut = () => {
		this.template.querySelector('c-cpq-configurator-popover').hide();
	}
}