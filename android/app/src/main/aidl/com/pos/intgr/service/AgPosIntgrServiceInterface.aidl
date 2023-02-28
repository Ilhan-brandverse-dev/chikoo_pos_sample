// AgPosIntgrServiceInterface.aidl
package com.pos.intgr.service;

interface AgPosIntgrServiceInterface {
    /**
     * Demonstrates some basic types that you can use as parameters
     * and return values in AIDL.
     */
    String processPosRequest(String requset);

    String getStatus(String refNumber);
}