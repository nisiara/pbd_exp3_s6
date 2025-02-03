ALTER SESSION SET NLS_TERRITORY = 'CHILE';
ALTER SESSION SET NLS_LANGUAGE = 'SPANISH';

/*
CREATE OR REPLACE FUNCTION fn_calculo_gc(p_nro_depto NUMBER, p_id_edif NUMBER)
    RETURN NUMBER IS
    -- Espacio para declarar variables
    BEGIN
    
    RETURN
    END;
END fn_calculo_gc;
*/

--CREATE OR REPLACE PROCEDURE sp_deptos_sin_pago_gc(p_periodo_proceso NUMBER, valor_uf NUMBER) IS
--v_error_msj VARCHAR2(250);

DECLARE

    r_gc_pago_cero Gasto_Comun_Pago_Cero%ROWTYPE;
    r_gc Gasto_Comun%ROWTYPE;
    
    CURSOR c_edificios IS
        SELECT 
            e.id_edif
            ,e.nombre_edif
            ,a.numrun_adm
            ,a.dvrun_adm
            ,a.pnombre_adm
            ,a.appaterno_adm
            ,a.apmaterno_adm
        FROM
            Edificio e
            INNER JOIN Administrador a ON e.numrun_adm = a.numrun_adm
        ORDER BY
            nombre_edif;
            
          
    CURSOR c_detalle_deuda(vc_id_edif NUMBER) IS
        SELECT
            nro_depto
        FROM 
            Departamento d
        WHERE 
            id_edif = vc_id_edif
            AND 
            d.nro_depto NOT IN (
            (SELECT nro_depto FROM Pago_Gasto_Comun WHERE id_edif = vc_id_edif AND anno_mes_pcgc = 202504)
        );
              
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE Gasto_Comun_Pago_Cero';
    
    FOR r_fila_edificio IN c_edificios LOOP
        
        FOR r_fila_detalle IN c_detalle_deuda(r_fila_edificio.id_edif) LOOP
            
            r_gc_pago_cero.anno_mes_pcgc := 202505;
            r_gc_pago_cero.id_edif := r_fila_edificio.id_edif;
            r_gc_pago_cero.nombre_edif := r_fila_edificio.nombre_edif;
            r_gc_pago_cero.run_administrador := 
                LPAD( 
                    TO_CHAR( SUBSTR(r_fila_edificio.numrun_adm, 1, LENGTH(r_fila_edificio.numrun_adm) - 6) ), 2, '0' ) || '.' ||
                    TO_CHAR( SUBSTR(r_fila_edificio.numrun_adm, LENGTH(r_fila_edificio.numrun_adm) - 5, 3 ) ) || '.' ||
                    TO_CHAR( SUBSTR(r_fila_edificio.numrun_adm, LENGTH(r_fila_edificio.numrun_adm) - 2, 3 ) || '-' || r_fila_edificio.dvrun_adm
                );
            r_gc_pago_cero.nombre_admnistrador := 
                INITCAP(
                    r_fila_edificio.pnombre_adm || ' ' || 
                    r_fila_edificio.appaterno_adm || ' ' || 
                    r_fila_edificio.apmaterno_adm
                );
            r_gc_pago_cero.nro_depto := r_fila_detalle.nro_depto;
            r_gc_pago_cero.run_responsable_pago_gc := 1;
            r_gc_pago_cero.nombre_responsable_pago_gc := 'nombre';
            r_gc_pago_cero.valor_multa_pago_cero := 100;
            r_gc_pago_cero.observacion := 'Observacion';
            
            INSERT INTO Gasto_Comun_Pago_Cero VALUES r_gc_pago_cero;
              
        END LOOP;
        
        
    END LOOP;  
END;

/

SELECT * FROM Gasto_Comun_Pago_Cero;

SELECT nro_depto FROM Gasto_Comun WHERE id_epago = 3;

SELECT * FROM Estado_Periodo;
SELECT * FROM Estado_Pago;

SELECT * FROM ESTADO_PERIODO;
SELECT * FROM PERIODO_COBRO_GASTO_COMUN;

SELECT * FROM PAGO_GASTO_COMUN
WHERE id_edif = 40 and nro_depto = 30;

SELECT * FROM RESUMEN_GASTO_COMUN;
--END pa_deptos_sin_pago_gc;

EXEC pa_gasto_comun(SYSDATE);


    

  
    
