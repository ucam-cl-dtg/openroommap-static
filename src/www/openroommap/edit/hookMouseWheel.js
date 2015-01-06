/*******************************************************************************
 * Copyright 2014 Digital Technology Group, Computer Laboratory
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and limitations under the License.
 *******************************************************************************/
function isOverSwf(mEvent)
{
	var elem;
	if (mEvent.srcElement) {
		elem = mEvent.srcElement;
	} else if (mEvent.target) {
		elem = mEvent.target;
	}
	if (elem.nodeName.toLowerCase() == "object" || elem.nodeName.toLowerCase() == "embed") {
			if (elem.getAttribute("classid") == "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000") {
				return true;
			}
			if (elem.getAttribute("type") == "application/x-shockwave-flash") {
				return true;
			}
	}
	return false;
}

function onMouseWheel(event)
{
	if (!event)
		event = window.event;

	if (isOverSwf(event)) {
		return cancelEvent(event);
	}

	return true;
}

function cancelEvent(e)
{
	e = e ? e : window.event;
	if (e.stopPropagation)
		e.stopPropagation();
	if (e.preventDefault)
		e.preventDefault();
	e.cancelBubble = true;
	e.cancel = true;
	e.returnValue = false;
	return false;
}
if (window.addEventListener) window.addEventListener('DOMMouseScroll', onMouseWheel, false);
window.onmousewheel = document.onmousewheel = onMouseWheel;